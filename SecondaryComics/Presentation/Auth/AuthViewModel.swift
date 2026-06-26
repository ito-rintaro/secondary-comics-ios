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
    private let store: UserDefaults
    /// 「過去にサインインに成功したか」の永続フラグ。起動時オフラインでの状態維持に使う。
    private static let wasSignedInKey = "auth.wasSignedIn"

    private(set) var phase: AuthPhase = .restoring
    /// サインイン処理中フラグ（ボタンのスピナー / 二重押下防止）。
    private(set) var isSubmitting = false
    /// 直近のエラーメッセージ（ログイン画面に表示）。
    var errorMessage: String?

    init(service: AuthService, store: UserDefaults = .standard) {
        self.service = service
        self.store = store
    }

    private var wasSignedIn: Bool {
        get { store.bool(forKey: Self.wasSignedInKey) }
        set { store.set(newValue, forKey: Self.wasSignedInKey) }
    }

    /// 起動時に呼ぶ。永続化済みセッションがあれば自動ログイン。
    /// 起動時にネットワーク不通でも、前回ログイン済みなら維持する（無効なら最初の API 401 で再ログインへ）。
    func restore() async {
        switch await service.restoreSession() {
        case .signedIn:
            wasSignedIn = true
            phase = .signedIn
        case .signedOut:
            wasSignedIn = false
            phase = .signedOut
        case .indeterminate:
            phase = wasSignedIn ? .signedIn : .signedOut
        }
    }

    func signIn(email: String, password: String) async {
        guard !isSubmitting else { return }
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await service.signIn(email: email, password: password)
            wasSignedIn = true
            phase = .signedIn
        } catch {
            errorMessage = error.localizedDescription
            phase = .signedOut
        }
    }

    func signOut() async {
        await service.signOut()
        wasSignedIn = false
        phase = .signedOut
    }

    /// 401 を受けた際の強制サインアウト（再ログイン導線）。
    func forceSignedOut() {
        wasSignedIn = false
        errorMessage = "ログインの有効期限が切れました。再度ログインしてください。"
        phase = .signedOut
    }
}
