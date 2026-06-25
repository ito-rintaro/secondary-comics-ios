import Foundation

/// コレクションの所有品。
/// 金額はすべて「1 点・円」（qty で掛ける前の単価）。
public struct CollectionItem: Codable, Sendable, Identifiable, Equatable {
    public var id: String
    public var title: String          // 作品名（必須）
    public var author: String         // 著者
    public var publisher: String      // 出版社 / レーベル
    public var volume: String         // 巻数（"全6巻" 等の自由文字列）
    public var year: String           // 発行年（文字列）
    public var condition: Condition   // 状態ランク
    public var qty: Int               // 所有数（>= 1）
    public var cost: Int              // 取得価格（1 点・円）
    public var market: Int            // 現在相場（1 点・円）
    public var marketSource: MarketSource // 相場の出所
    public var flags: ConditionFlags  // 初版 / 帯 / 特装
    public var purchaseDate: String   // 購入日 YYYY-MM-DD（未入力は空文字）
    public var store: String          // 購入店
    public var location: String       // 保管場所
    public var memo: String           // メモ
    public var imageUrl: String       // S3 オブジェクトキー（空可）
    public var updatedAt: Int64        // 最終更新（epoch ミリ秒）

    public init(
        id: String,
        title: String,
        author: String = "",
        publisher: String = "",
        volume: String = "",
        year: String = "",
        condition: Condition = .a,
        qty: Int = 1,
        cost: Int = 0,
        market: Int = 0,
        marketSource: MarketSource = .manual,
        flags: ConditionFlags = ConditionFlags(),
        purchaseDate: String = "",
        store: String = "",
        location: String = "",
        memo: String = "",
        imageUrl: String = "",
        updatedAt: Int64 = 0
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.publisher = publisher
        self.volume = volume
        self.year = year
        self.condition = condition
        self.qty = qty
        self.cost = cost
        self.market = market
        self.marketSource = marketSource
        self.flags = flags
        self.purchaseDate = purchaseDate
        self.store = store
        self.location = location
        self.memo = memo
        self.imageUrl = imageUrl
        self.updatedAt = updatedAt
    }
}
