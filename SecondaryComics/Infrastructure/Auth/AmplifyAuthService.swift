import Amplify
import AWSCognitoAuthPlugin
import Foundation

/// Amplify(Cognito) 実装の `AuthService`。Web 版（Amplify JS）と同じ User Pool / 認証フローに接続する。
struct AmplifyAuthService: AuthService {
    func signIn(email: String, password: String) async throws {
        let result: AuthSignInResult
        do {
            result = try await Amplify.Auth.signIn(username: email, password: password)
        } catch let error as AuthError {
            throw Self.map(error)
        } catch {
            throw AuthServiceError.unknown(error.localizedDescription)
        }

        // MFA / 新パスワード要求等の追加ステップは MVP 非対応。完了のみ成功扱い。
        guard result.isSignedIn else {
            throw AuthServiceError.additionalStepRequired
        }
    }

    func signOut() async {
        _ = await Amplify.Auth.signOut()
    }

    /// Amplify はトークン（refresh token 含む）を Keychain に永続化するため、
    /// アプリ再起動後も `fetchAuthSession()` でセッションを復元できる（期限切れトークンは自動更新）。
    func restoreSession() async -> SessionRestoreResult {
        do {
            // 未サインインでも throw はせず isSignedIn = false の session が返る。
            let session = try await Amplify.Auth.fetchAuthSession()
            return session.isSignedIn ? .signedIn : .signedOut
        } catch {
            // 取得自体に失敗（多くは起動時のネットワーク不通）→ 判定保留。
            return .indeterminate
        }
    }

    /// Amplify の `AuthError` を UI 表示用の `AuthServiceError` へ写像する。
    private static func map(_ error: AuthError) -> AuthServiceError {
        switch error {
        case .notAuthorized:
            return .invalidCredentials
        case let .service(_, _, underlyingError):
            if underlyingError is AWSCognitoAuthError {
                switch underlyingError as? AWSCognitoAuthError {
                case .userNotConfirmed:
                    return .userNotConfirmed
                case .userNotFound:
                    return .invalidCredentials
                default:
                    break
                }
            }
            return .unknown(error.errorDescription)
        default:
            return .unknown(error.errorDescription)
        }
    }
}
