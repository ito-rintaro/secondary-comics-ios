import Foundation

// マーケットの検索・ソート（すべてクライアント側）。

public enum MarketSort: String, Sendable, CaseIterable {
    case priceDesc // 価格高い順（既定）
    case trendDesc // 値上がり率高い順
    case newest    // 新着順（listedAt 降順）

    public var label: String {
        switch self {
        case .priceDesc: return "価格高い順"
        case .trendDesc: return "値上がり率高い順"
        case .newest: return "新着順"
        }
    }
}

/// 検索 → ソートをこの順で適用する。
public func applyMarketQuery(
    _ records: [MarketRecord],
    search: String = "",
    sort: MarketSort = .priceDesc
) -> [MarketRecord] {
    var result = records

    let needle = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if !needle.isEmpty {
        result = result.filter { record in
            record.title.lowercased().contains(needle)
                || record.author.lowercased().contains(needle)
                || record.publisher.lowercased().contains(needle)
                || record.seller.lowercased().contains(needle)
        }
    }

    switch sort {
    case .priceDesc: result.sort { $0.price > $1.price }
    case .trendDesc: result.sort { $0.change > $1.change }
    case .newest: result.sort { $0.listedAt > $1.listedAt }
    }

    return result
}
