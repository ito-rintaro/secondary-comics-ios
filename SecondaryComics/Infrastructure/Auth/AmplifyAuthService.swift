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

    func isSignedIn() async -> Bool {
        guard let session = try? await Amplify.Auth.fetchAuthSession() else { return false }
        return session.isSignedIn
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
