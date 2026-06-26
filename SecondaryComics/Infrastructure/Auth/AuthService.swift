import Foundation

/// ログイン状態を操作する認証サービスの抽象。
/// Presentation（`AuthViewModel`）はこの protocol だけに依存し、Amplify には直接触らない。
/// → プレビューや Demo では `StubAuthService` を差し替えられる。
protocol AuthService: Sendable {
    /// メールアドレス + パスワードでサインインする。成功で完了、それ以外は `AuthServiceError` を投げる。
    func signIn(email: String, password: String) async throws
    /// サインアウトする（失敗してもローカル状態はクリアする想定）。
    func signOut() async
    /// 既存セッションでサインイン済みか（起動時の自動ログイン判定に使う）。
    func isSignedIn() async -> Bool
}

/// 認証操作のエラー。UI でそのまま表示できる日本語メッセージを持つ。
enum AuthServiceError: LocalizedError {
    case invalidCredentials
    case userNotConfirmed
    case network
    case additionalStepRequired
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "メールアドレスまたはパスワードが正しくありません。"
        case .userNotConfirmed:
            return "アカウントが未確認です。確認を完了してください。"
        case .network:
            return "ネットワークに接続できませんでした。"
        case .additionalStepRequired:
            return "追加の認証手続きが必要です。Web 版でログインを完了してください。"
        case let .unknown(message):
            return message
        }
    }
}
