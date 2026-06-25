import Foundation
import Observation
import SecondaryComicsCore

/// マイコレクション一覧の ViewModel。iOS 17 の @Observable。
@MainActor
@Observable
final class CollectionListModel {
    private let listCollection: ListCollection

    var state: LoadState<[CollectionItem]> = .idle
    var search: String = ""
    var filter: CollectionFilter = .all
    var sort: CollectionSort = .updated

    init(listCollection: ListCollection) {
        self.listCollection = listCollection
    }

    /// 検索 → フィルタ → ソートを適用した表示用リスト。
    var visibleItems: [CollectionItem] {
        guard case let .loaded(items) = state else { return [] }
        return applyCollectionQuery(items, search: search, filter: filter, sort: sort)
    }

    /// 全件サマリー（フィルタ非依存）。
    var summary: CollectionSummary {
        guard case let .loaded(items) = state else {
            return CollectionSummary(count: 0, totalCost: 0, totalValue: 0, pl: 0)
        }
        return summarize(items)
    }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await listCollection())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
