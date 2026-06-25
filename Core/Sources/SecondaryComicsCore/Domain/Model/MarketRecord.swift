import Foundation

/// マーケットの相場レコード（全ユーザー共通・グローバル）。
public struct MarketRecord: Codable, Sendable, Identifiable, Equatable {
    public var id: String
    public var title: String
    public var author: String
    public var publisher: String
    public var volume: String
    public var seller: String         // 出品者 / ショップ名
    public var condition: Condition
    public var flags: ConditionFlags
    public var history: [Int]         // 直近 12 ヶ月の価格推移（円）。要素数 12。末尾が現在価格
    public var price: Int             // 現在価格（= history の末尾）
    public var change: Double         // 期間変化率 (末尾 - 先頭) / 先頭。0.18 → +18%
    public var listedAt: Int64        // 新着ソート用の連番（大きいほど新しい）
    public var imageUrl: String       // S3 オブジェクトキー（空可）

    public init(
        id: String,
        title: String,
        author: String = "",
        publisher: String = "",
        volume: String = "",
        seller: String = "",
        condition: Condition = .a,
        flags: ConditionFlags = ConditionFlags(),
        history: [Int] = [],
        price: Int = 0,
        change: Double = 0,
        listedAt: Int64 = 0,
        imageUrl: String = ""
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.publisher = publisher
        self.volume = volume
        self.seller = seller
        self.condition = condition
        self.flags = flags
        self.history = history
        self.price = price
        self.change = change
        self.listedAt = listedAt
        self.imageUrl = imageUrl
    }
}
