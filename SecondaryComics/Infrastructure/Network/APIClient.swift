import Foundation

/// Cognito トークンを付与して JSON を送受信する薄い HTTP クライアント（Web の apiClient.ts 相当）。
final class APIClient: Sendable {
    private let baseURL: URL
    private let tokenProvider: TokenProvider
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    /// - Parameter baseURL: API Gateway のベース URL（末尾スラッシュ有無は問わない）。
    init(baseURL: URL, tokenProvider: TokenProvider, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    /// `path`（例: "/collection"）へ GET し、`T` としてデコードして返す。
    /// `Authorization: Bearer <ID トークン>` を自動付与する。
    func get<T: Decodable>(_ path: String, as type: T.Type = T.self) async throws -> T {
        var request = URLRequest(url: url(for: path))
        request.httpMethod = "GET"
        return try await send(request, as: T.self)
    }

    /// `path`（例: "/collection"）へ `body` を JSON 化して POST し、`T` としてデコードして返す。
    /// `Authorization: Bearer <ID トークン>` を自動付与する。
    func post<Body: Encodable, T: Decodable>(
        _ path: String,
        body: Body,
        as type: T.Type = T.self
    ) async throws -> T {
        var request = URLRequest(url: url(for: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            throw APIError.decoding
        }
        return try await send(request, as: T.self)
    }

    /// 共通の送信処理。認証ヘッダ付与・通信・ステータス判定・デコードをまとめる。
    private func send<T: Decodable>(_ baseRequest: URLRequest, as type: T.Type) async throws -> T {
        let token = try await tokenProvider.idToken()

        var request = baseRequest
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
            // サーバーが本文 `{ "message": "..." }` を返していればそれを優先表示する。
            if let message = decodeErrorMessage(from: data) {
                throw APIError.server(status: http.statusCode, message: message)
            }
            throw APIError.http(status: http.statusCode)
        }
    }

    /// エラー本文（OpenAPI の `Error`）から `message` を取り出す。取り出せなければ nil。
    private func decodeErrorMessage(from data: Data) -> String? {
        struct ServerError: Decodable { let message: String }
        guard let parsed = try? decoder.decode(ServerError.self, from: data),
              !parsed.message.isEmpty else {
            return nil
        }
        return parsed.message
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
