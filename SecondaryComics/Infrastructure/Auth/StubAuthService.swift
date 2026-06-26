import Foundation

/// Demo モード / プレビュー用のダミー認証。常にサインイン済みとして扱い、ログインゲートを素通りさせる。
struct StubAuthService: AuthService {
    /// 起動時に「サインイン済み」とみなしてゲートを通すか。
    var signedIn: Bool = true

    func signIn(email: String, password: String) async throws {}
    func signOut() async {}
    func restoreSession() async -> SessionRestoreResult { signedIn ? .signedIn : .signedOut }
}

/// Demo / プレビュー用のトークン供給。Demo リポジトリはトークンを使わないためダミー値を返す。
struct StubTokenProvider: TokenProvider {
    func idToken() async throws -> String { "demo-token" }
}
