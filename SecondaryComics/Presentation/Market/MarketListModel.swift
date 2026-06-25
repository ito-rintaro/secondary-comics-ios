import Foundation
import Observation
import SecondaryComicsCore

/// マーケット一覧の ViewModel。
@MainActor
@Observable
final class MarketListModel {
    private let listMarket: ListMarket

    var state: LoadState<[MarketRecord]> = .idle
    var search: String = ""
    var sort: MarketSort = .priceDesc

    init(listMarket: ListMarket) {
        self.listMarket = listMarket
    }

    var visibleRecords: [MarketRecord] {
        guard case let .loaded(records) = state else { return [] }
        return applyMarketQuery(records, search: search, sort: sort)
    }

    var summary: MarketSummary {
        guard case let .loaded(records) = state else {
            return MarketSummary(count: 0, topPrice: 0, avgPrice: 0, avgChange: 0)
        }
        return summarizeMarket(records)
    }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await listMarket())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
