import Foundation

/// 画像 URL の解決（Web の src/presentation/imageSrc.ts のロジック）。
enum ImageURLResolver {
    /// imageUrl（S3 オブジェクトキー or 絶対 URL）を表示用 URL へ解決する。
    /// 空文字 → nil（プレースホルダ表示）。http(s):/data: → そのまま。それ以外 → {imageBaseURL}/images/{key}。
    static func resolve(_ imageUrl: String, imageBaseURL: String) -> URL? {
        let value = imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty { return nil }

        if value.hasPrefix("http://") || value.hasPrefix("https://") || value.hasPrefix("data:") {
            return URL(string: value)
        }

        // S3 キー: 先頭の / を除去して結合
        let key = value.hasPrefix("/") ? String(value.dropFirst()) : value
        let base = imageBaseURL.hasSuffix("/") ? String(imageBaseURL.dropLast()) : imageBaseURL
        return URL(string: "\(base)/images/\(key)")
    }
}
