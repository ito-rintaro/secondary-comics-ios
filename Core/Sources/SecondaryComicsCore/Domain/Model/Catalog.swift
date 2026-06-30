import Foundation

/// 書誌マスタ（Catalog）1 件。Collection / MarketRecord が catalogId で参照する hub。
/// 全ユーザー共通（グローバル）データで、`GET /catalogs` で取得する。
/// プロパティ名は OpenAPI の `Catalog` と一致させる（追加マッピング不要）。
public struct Catalog: Codable, Sendable, Identifiable, Equatable {
    public var id: String              // カタログ識別子（cat-xxx）
    public var title: String           // 作品名
    public var author: String          // 著者
    public var publisher: String       // 出版社 / レーベル
    public var volume: String          // 巻数（自由文字列）
    public var year: String            // 発行年（文字列）
    public var flags: ConditionFlags   // 初版 / 帯 / 特装
    public var imageUrl: String        // S3 オブジェクトキー（空可）

    public init(
        id: String,
        title: String,
        author: String = "",
        publisher: String = "",
        volume: String = "",
        year: String = "",
        flags: ConditionFlags = ConditionFlags(),
        imageUrl: String = ""
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.publisher = publisher
        self.volume = volume
        self.year = year
        self.flags = flags
        self.imageUrl = imageUrl
    }

    /// 検索対象文字列（title / author / publisher / volume / year を空白連結）。
    /// 部分一致検索（大文字小文字無視）に使う。
    public var searchText: String {
        [title, author, publisher, volume, year].joined(separator: " ")
    }

    /// 一覧表示用メタ情報（著者・巻数・出版社・発行年を ` ・ ` 連結。空要素は除外）。
    public var metaLine: String {
        [author, volume, publisher, year]
            .filter { !$0.isEmpty }
            .joined(separator: " ・ ")
    }
}
