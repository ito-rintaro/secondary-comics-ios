import Foundation

/// 環境設定値。
/// Cognito / API / 画像配信の各ベース値を保持する。いずれもクライアントに同梱される公開値
/// （terraform output / GitHub Environments と同値）。
///
/// dev / prod の切り替えはビルド構成のコンパイルフラグで行う:
/// - Debug ビルド（`DEV`） → `AppConfig.dev`
/// - Release ビルド（`PROD`） → `AppConfig.prod`
/// アプリ本体は `AppConfig.current` だけを参照する。
struct AppConfig {
    let cognitoUserPoolId: String
    let cognitoClientId: String
    let awsRegion: String
    /// API Gateway のベース URL（末尾スラッシュ無し）。
    let apiBaseURL: String
    /// CloudFront ドメイン（画像配信元、末尾スラッシュ無し）。画像 URL 解決で使用。
    let imageBaseURL: String
    /// true なら実 API（+ Cognito 認証）に接続。false なら Demo モード（Web の VITE_USE_API 相当）。
    let useAPI: Bool

    /// ビルド構成に応じた現在の環境設定。
    static var current: AppConfig {
        #if PROD
        return .prod
        #else
        return .dev
        #endif
    }

    /// 認証 / API を無効化した Demo プレースホルダ。プレビューや API 不在時の確認用。
    static let placeholder = AppConfig(
        cognitoUserPoolId: "",
        cognitoClientId: "",
        awsRegion: "ap-northeast-1",
        apiBaseURL: "",
        imageBaseURL: "",
        useAPI: false
    )

    /// dev 環境。Web の `.env.dev` と同値（クライアント公開値）。
    static let dev = AppConfig(
        cognitoUserPoolId: "ap-northeast-1_lvEOCAFnu",
        cognitoClientId: "2mpap5bool3cskl6uujogpm2n7",
        awsRegion: "ap-northeast-1",
        apiBaseURL: "https://upu69qvm0e.execute-api.ap-northeast-1.amazonaws.com",
        imageBaseURL: "https://d1hcydkbqi86gl.cloudfront.net",
        useAPI: true
    )

    /// prod 環境。実値が決まり次第ここを埋める（terraform output / GitHub Environments の prod 値）。
    /// 空のままでは Release ビルドで API/認証が機能しないので注意。
    static let prod = AppConfig(
        cognitoUserPoolId: "",
        cognitoClientId: "",
        awsRegion: "ap-northeast-1",
        apiBaseURL: "",
        imageBaseURL: "",
        useAPI: true
    )
}
