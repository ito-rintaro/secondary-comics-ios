import Foundation

/// 環境設定値。
/// 実値は dev/prod ごとに異なり、リポジトリにはコミットされていない（terraform output / GitHub Environments より取得）。
/// MVP の Demo モードでは API/Cognito 値は未使用。実 API 接続フェーズ（Phase 4）で埋める。
struct AppConfig {
    let cognitoUserPoolId: String
    let cognitoClientId: String
    let awsRegion: String
    let apiBaseURL: String
    /// CloudFront ドメイン（画像配信元、末尾スラッシュ無し）。画像 URL 解決で使用。
    let imageBaseURL: String

    /// プレースホルダ。Phase 4 で Info.plist / xcconfig / 環境変数から注入する。
    static let placeholder = AppConfig(
        cognitoUserPoolId: "",
        cognitoClientId: "",
        awsRegion: "ap-northeast-1",
        apiBaseURL: "",
        imageBaseURL: ""
    )
}
