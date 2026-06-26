import Amplify
import AWSCognitoAuthPlugin
import Foundation

/// アプリ起動時に一度だけ Amplify を初期化する。
/// 設定は `AppConfig`（dev/prod で切替）の値からプログラム的に構成する。
/// → 環境ごとの `amplifyconfiguration.json` を持たずに済む。
enum AmplifyConfigurator {
    private static var configured = false

    static func configure(with config: AppConfig) {
        guard !configured else { return }
        configured = true
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure(amplifyConfiguration(for: config))
        } catch {
            // 設定不備や二重 configure はログのみ（Demo モードでは認証を使わないため致命ではない）。
            print("[Amplify] configure failed: \(error)")
        }
    }

    /// Cognito User Pool 認証のみの最小構成。Web 版（Amplify JS）と同じ USER_SRP_AUTH。
    private static func amplifyConfiguration(for config: AppConfig) -> AmplifyConfiguration {
        let cognitoPlugin: JSONValue = [
            "CognitoUserPool": [
                "Default": [
                    "PoolId": .string(config.cognitoUserPoolId),
                    "AppClientId": .string(config.cognitoClientId),
                    "Region": .string(config.awsRegion)
                ]
            ],
            "Auth": [
                "Default": [
                    "authenticationFlowType": "USER_SRP_AUTH"
                ]
            ]
        ]
        let auth = AuthCategoryConfiguration(plugins: ["awsCognitoAuthPlugin": cognitoPlugin])
        return AmplifyConfiguration(auth: auth)
    }
}
