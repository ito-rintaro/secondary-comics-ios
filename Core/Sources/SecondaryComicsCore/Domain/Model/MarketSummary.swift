import Foundation

/// catalog 単位の相場サマリ。成約ログ（`MarketSale`）を集計・導出した読み取りモデルで、
/// 相場一覧カードと価格チャートの供給源になる（`GET /market/summary`）。
/// `price` / `change` / `history` は名前も意味も従来の `MarketRecord` から据え置き。
/// 成約が 1 件以上ある catalog のみ返る（成約 0 件の catalog は含まれない）。
/// プロパティ名は OpenAPI の `MarketSummary` と一致させる（追加マッピング不要）。
public struct MarketSummary: Codable, Sendable, Identifiable, Equatable {
    public var catalogId: String       // 集計単位＝参照する Catalog の id
    public var title: String           // 作品名（Catalog 由来）
    public var author: String          // 著者（Catalog 由来）
    public var publisher: String       // 出版社 / レーベル（Catalog 由来）
    public var volume: String          // 巻数（Catalog 由来・自由文字列）
    public var flags: ConditionFlags   // 初版 / 帯 / 特装（Catalog 由来）
    public var imageUrl: String        // S3 オブジェクトキー（Catalog 由来・空可）
    public var price: Int              // 現在価格（円）＝ history 末尾（直近月バケット）
    public var change: Double          // 変化率 (history 末尾 - 先頭) / 先頭。0.18 → +18%
    public var history: [Int]          // 月次に畳んだ擬似系列（円）。要素数 12・末尾＝当月
    public var sampleCount: Int        // 集計に使った成約点数（相場の信頼度の目安）
    public var lastSoldAt: String      // 直近成約日（"YYYY-MM-DD"）

    /// `Identifiable` は集計単位である catalogId を用いる。
    public var id: String { catalogId }

    public init(
        catalogId: String,
        title: String,
        author: String = "",
        publisher: String = "",
        volume: String = "",
        flags: ConditionFlags = ConditionFlags(),
        imageUrl: String = "",
        price: Int = 0,
        change: Double = 0,
        history: [Int] = [],
        sampleCount: Int = 0,
        lastSoldAt: String = ""
    ) {
        self.catalogId = catalogId
        self.title = title
        self.author = author
        self.publisher = publisher
        self.volume = volume
        self.flags = flags
        self.imageUrl = imageUrl
        self.price = price
        self.change = change
        self.history = history
        self.sampleCount = sampleCount
        self.lastSoldAt = lastSoldAt
    }
}
