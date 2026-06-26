import Foundation
import Observation

/// 認証セッションの状態。アプリのルートはこれで「ログイン画面 / 本体」を出し分ける。
enum AuthPhase: Equatable {
    /// 起動直後。既存セッションの有無を確認中。
    case restoring
    /// 未ログイン。ログイン画面を出す。
    case signedOut
    /// ログイン済み。本体（TabView）を出す。
    case signedIn
}

/// ログイン状態を司る ViewModel。`AuthService` に処理を委ね、UI 状態だけを保持する。
@MainActor
@Observable
final class AuthViewModel {
    private let service: AuthService

    private(set) var phase: AuthPhase = .restoring
    /// サインイン処理中フラグ（ボタンのスピナー / 二重押下防止）。
    private(set) var isSubmitting = false
    /// 直近のエラーメッセージ（ログイン画面に表示）。
    var errorMessage: String?

    init(service: AuthService) {
        self.service = service
    }

    /// 起動時に呼ぶ。既存セッションがあればそのまま本体へ。
    func restore() async {
        phase = await service.isSignedIn() ? .signedIn : .signedOut
    }

    func signIn(email: String, password: String) async {
        guard !isSubmitting else { return }
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await service.signIn(email: email, password: password)
            phase = .signedIn
        } catch {
            errorMessage = error.localizedDescription
            phase = .signedOut
        }
    }

    func signOut() async {
        await service.signOut()
        phase = .signedOut
    }

    /// 401 を受けた際の強制サインアウト（再ログイン導線）。
    func forceSignedOut() {
        errorMessage = "ログインの有効期限が切れました。再度ログインしてください。"
        phase = .signedOut
    }
}
