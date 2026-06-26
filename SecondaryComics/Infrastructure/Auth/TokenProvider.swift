import Foundation

/// API リクエストに付与する Cognito ID トークンの供給源。
/// ネットワーク層（`APIClient`）はこの抽象だけに依存し、Cognito SDK には依存しない。
/// 実装は Amplify（`AmplifyTokenProvider`）。トークンの取得・自動更新は実装側に委ねる。
protocol TokenProvider: Sendable {
    /// 有効な ID トークンを返す。未ログイン / 取得不能なら `APIError.unauthorized` を投げる。
    func idToken() async throws -> String
}
