import Foundation

// マーケット相場（catalog 単位のサマリ）の検索・ソート（すべてクライアント側）。

public enum MarketSort: String, Sendable, CaseIterable {
    case priceDesc  // 価格高い順（既定）
    case trendDesc  // 値上がり率高い順
    case recentDesc // 直近成約が新しい順（lastSoldAt 降順）

    public var label: String {
        switch self {
        case .priceDesc: return "価格高い順"
        case .trendDesc: return "値上がり率高い順"
        case .recentDesc: return "直近成約順"
        }
    }
}

/// 検索 → ソートをこの順で適用する。
/// 検索は書誌（title / author / publisher）を対象にする。相場サマリは catalog 単位のため
/// seller（出品者）は持たない。ソートは price / change / lastSoldAt で行う。
public func applyMarketQuery(
    _ summaries: [MarketSummary],
    search: String = "",
    sort: MarketSort = .priceDesc
) -> [MarketSummary] {
    var result = summaries

    let needle = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if !needle.isEmpty {
        result = result.filter { summary in
            summary.title.lowercased().contains(needle)
                || summary.author.lowercased().contains(needle)
                || summary.publisher.lowercased().contains(needle)
        }
    }

    switch sort {
    case .priceDesc: result.sort { $0.price > $1.price }
    case .trendDesc: result.sort { $0.change > $1.change }
    case .recentDesc: result.sort { $0.lastSoldAt > $1.lastSoldAt }
    }

    return result
}
