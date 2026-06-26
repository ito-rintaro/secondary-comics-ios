import Foundation

/// API 通信のエラー。Presentation はこれを `localizedDescription` で表示し、
/// `.unauthorized` のときは再ログイン導線へ誘導する。
enum APIError: LocalizedError, Equatable {
    /// 401。トークン無効 / 期限切れ。再ログインが必要。
    case unauthorized
    /// HTTP レスポンスが想定外（非 HTTPURLResponse など）。
    case invalidResponse
    /// 2xx 以外（401 を除く）。
    case http(status: Int)
    /// レスポンス本文の JSON デコード失敗。
    case decoding
    /// 通信そのものの失敗（オフライン等）。
    case transport

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "ログインの有効期限が切れました。再度ログインしてください。"
        case .invalidResponse:
            return "サーバーから不正な応答が返りました。"
        case let .http(status):
            return "通信に失敗しました（HTTP \(status)）。"
        case .decoding:
            return "データの解析に失敗しました。"
        case .transport:
            return "ネットワークに接続できませんでした。通信環境を確認してください。"
        }
    }
}
