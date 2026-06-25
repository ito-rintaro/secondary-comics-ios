import Foundation

// コレクションの検索・フィルタ・ソート（すべてクライアント側）。

public enum CollectionFilter: String, Sendable, CaseIterable {
    case all       // すべて
    case firstEd   // 初版
    case obi       // 帯
    case special   // 特装
    case profit    // 含み益
    case loss      // 含み損

    public var label: String {
        switch self {
        case .all: return "すべて"
        case .firstEd: return "初版"
        case .obi: return "帯"
        case .special: return "特装"
        case .profit: return "含み益"
        case .loss: return "含み損"
        }
    }
}

public enum CollectionSort: String, Sendable, CaseIterable {
    case updated    // 更新新しい順（既定）
    case marketDesc // 相場高い順
    case plDesc     // 損益大きい順
    case titleAsc   // タイトル順

    public var label: String {
        switch self {
        case .updated: return "更新順"
        case .marketDesc: return "相場高い順"
        case .plDesc: return "損益大きい順"
        case .titleAsc: return "タイトル順"
        }
    }
}

/// 検索 → フィルタ → ソートをこの順で適用する。
public func applyCollectionQuery(
    _ items: [CollectionItem],
    search: String = "",
    filter: CollectionFilter = .all,
    sort: CollectionSort = .updated
) -> [CollectionItem] {
    var result = items

    // 検索: title / author / publisher への部分一致（大小無視）
    let needle = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if !needle.isEmpty {
        result = result.filter { item in
            item.title.lowercased().contains(needle)
                || item.author.lowercased().contains(needle)
                || item.publisher.lowercased().contains(needle)
        }
    }

    // フィルタ
    switch filter {
    case .all: break
    case .firstEd: result = result.filter { $0.flags.firstEd }
    case .obi: result = result.filter { $0.flags.obi }
    case .special: result = result.filter { $0.flags.special }
    case .profit: result = result.filter { $0.profitLoss > 0 }
    case .loss: result = result.filter { $0.profitLoss < 0 }
    }

    // ソート
    switch sort {
    case .updated: result.sort { $0.updatedAt > $1.updatedAt }
    case .marketDesc: result.sort { $0.market > $1.market }
    case .plDesc: result.sort { $0.profitLoss > $1.profitLoss }
    case .titleAsc: result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    return result
}
