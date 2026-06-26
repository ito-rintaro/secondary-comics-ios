import Foundation

/// Cognito トークンを付与して JSON を取得する薄い HTTP クライアント（Web の apiClient.ts 相当）。
/// GET のみ稼働のため GET だけを提供する。書き込み API 提供時にメソッドを足す。
final class APIClient: Sendable {
    private let baseURL: URL
    private let tokenProvider: TokenProvider
    private let session: URLSession
    private let decoder: JSONDecoder

    /// - Parameter baseURL: API Gateway のベース URL（末尾スラッシュ有無は問わない）。
    init(baseURL: URL, tokenProvider: TokenProvider, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.session = session
        self.decoder = JSONDecoder()
    }

    /// `path`（例: "/collection"）へ GET し、`T` としてデコードして返す。
    /// `Authorization: Bearer <ID トークン>` を自動付与する。
    func get<T: Decodable>(_ path: String, as type: T.Type = T.self) async throws -> T {
        let token = try await tokenProvider.idToken()

        var request = URLRequest(url: url(for: path))
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw APIError.transport
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch http.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decoding
            }
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.http(status: http.statusCode)
        }
    }

    /// ベース URL と `path` を結合する。二重スラッシュを避ける。
    private func url(for path: String) -> URL {
        let base = baseURL.absoluteString.hasSuffix("/")
            ? String(baseURL.absoluteString.dropLast())
            : baseURL.absoluteString
        let suffix = path.hasPrefix("/") ? path : "/\(path)"
        return URL(string: base + suffix) ?? baseURL
    }
}
