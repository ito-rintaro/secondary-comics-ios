import Foundation

/// マーケットの成約レコード 1 件（1 レコード = 1 価格の append-only な取引ログ）。
/// 全ユーザー共通（グローバル）で `GET /market` から取得する。相場（現在価格・変化率・
/// チャート系列）は集計した `MarketSummary`（`GET /market/summary`）側で導出する。
/// プロパティ名は OpenAPI の `MarketSale` と一致させる（追加マッピング不要）。
public struct MarketSale: Codable, Sendable, Identifiable, Equatable {
    public var id: String              // レコード識別子（mk-xxx）
    public var title: String           // 作品名（Catalog 由来）
    public var author: String          // 著者（Catalog 由来）
    public var publisher: String       // 出版社 / レーベル（Catalog 由来）
    public var volume: String          // 巻数（Catalog 由来・自由文字列）
    public var flags: ConditionFlags   // 初版 / 帯 / 特装（Catalog 由来）
    public var imageUrl: String        // S3 オブジェクトキー（Catalog 由来・空可）
    public var catalogId: String       // 参照する Catalog の id
    public var condition: Condition    // この成約個体の状態ランク
    public var price: Int              // 成約価格（円）＝単一
    public var soldAt: String          // 成約日（"YYYY-MM-DD"）
    public var seller: String          // 販売元 / ショップ名（空可）

    public init(
        id: String,
        title: String,
        author: String = "",
        publisher: String = "",
        volume: String = "",
        flags: ConditionFlags = ConditionFlags(),
        imageUrl: String = "",
        catalogId: String,
        condition: Condition = .a,
        price: Int = 0,
        soldAt: String = "",
        seller: String = ""
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.publisher = publisher
        self.volume = volume
        self.flags = flags
        self.imageUrl = imageUrl
        self.catalogId = catalogId
        self.condition = condition
        self.price = price
        self.soldAt = soldAt
        self.seller = seller
    }
}
