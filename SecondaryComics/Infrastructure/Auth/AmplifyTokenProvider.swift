import Amplify
import AWSPluginsCore
import Foundation

/// Amplify 経由で Cognito の ID トークンを供給する `TokenProvider`。
/// トークンの取得・期限切れ時の自動更新は Amplify が担う。
struct AmplifyTokenProvider: TokenProvider {
    func idToken() async throws -> String {
        let session: AuthSession
        do {
            session = try await Amplify.Auth.fetchAuthSession()
        } catch {
            throw APIError.unauthorized
        }

        guard
            let provider = session as? AuthCognitoTokensProvider,
            let tokens = try? provider.getCognitoTokens().get()
        else {
            throw APIError.unauthorized
        }
        return tokens.idToken
    }
}
