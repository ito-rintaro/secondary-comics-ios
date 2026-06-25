import Foundation

/// コレクション全体サマリー。
public struct CollectionSummary: Sendable, Equatable {
    public let count: Int       // 登録点数（所有数合計 Σ qty）
    public let totalCost: Int   // 総取得額 Σ acquisitionCost
    public let totalValue: Int  // 現在評価額 Σ evaluation
    public let pl: Int          // 含み損益 = totalValue - totalCost

    public init(count: Int, totalCost: Int, totalValue: Int, pl: Int) {
        self.count = count
        self.totalCost = totalCost
        self.totalValue = totalValue
        self.pl = pl
    }
}

/// マーケット全体サマリー。
public struct MarketSummary: Sendable, Equatable {
    public let count: Int        // records.count
    public let topPrice: Int     // max(price)
    public let avgPrice: Double   // mean(price)
    public let avgChange: Double  // mean(change)

    public init(count: Int, topPrice: Int, avgPrice: Double, avgChange: Double) {
        self.count = count
        self.topPrice = topPrice
        self.avgPrice = avgPrice
        self.avgChange = avgChange
    }
}

/// コレクション配列を集計する。空配列なら全て 0。
public func summarize(_ items: [CollectionItem]) -> CollectionSummary {
    let count = items.reduce(0) { $0 + $1.qty }
    let totalCost = items.reduce(0) { $0 + $1.acquisitionCost }
    let totalValue = items.reduce(0) { $0 + $1.evaluation }
    return CollectionSummary(
        count: count,
        totalCost: totalCost,
        totalValue: totalValue,
        pl: totalValue - totalCost
    )
}

/// マーケット配列を集計する。空配列なら全て 0（平均は 0）。
public func summarizeMarket(_ records: [MarketRecord]) -> MarketSummary {
    guard !records.isEmpty else {
        return MarketSummary(count: 0, topPrice: 0, avgPrice: 0, avgChange: 0)
    }
    let topPrice = records.map(\.price).max() ?? 0
    let avgPrice = Double(records.reduce(0) { $0 + $1.price }) / Double(records.count)
    let avgChange = records.reduce(0.0) { $0 + $1.change } / Double(records.count)
    return MarketSummary(
        count: records.count,
        topPrice: topPrice,
        avgPrice: avgPrice,
        avgChange: avgChange
    )
}
