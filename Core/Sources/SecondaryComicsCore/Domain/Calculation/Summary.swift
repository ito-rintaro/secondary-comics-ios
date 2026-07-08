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

/// マーケット全体のヘッダ集計（相場サマリ配列を横断して求める概況）。
/// catalog 単位の相場サマリ（`MarketSummary`）とは別物。
public struct MarketOverview: Sendable, Equatable {
    public let count: Int         // 相場のある銘柄数（summaries.count）
    public let topPrice: Int      // max(price)
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

/// 相場サマリ配列からヘッダ概況を集計する。空配列なら全て 0（平均は 0）。
public func summarizeMarket(_ summaries: [MarketSummary]) -> MarketOverview {
    guard !summaries.isEmpty else {
        return MarketOverview(count: 0, topPrice: 0, avgPrice: 0, avgChange: 0)
    }
    let topPrice = summaries.map(\.price).max() ?? 0
    let avgPrice = Double(summaries.reduce(0) { $0 + $1.price }) / Double(summaries.count)
    let avgChange = summaries.reduce(0.0) { $0 + $1.change } / Double(summaries.count)
    return MarketOverview(
        count: summaries.count,
        topPrice: topPrice,
        avgPrice: avgPrice,
        avgChange: avgChange
    )
}
