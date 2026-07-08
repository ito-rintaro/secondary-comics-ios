import Foundation
import Observation
import SecondaryComicsCore

/// マーケット相場一覧の ViewModel。catalog 単位の相場サマリ（`MarketSummary`）を扱う。
@MainActor
@Observable
final class MarketListModel {
    private let listMarketSummary: ListMarketSummary

    var state: LoadState<[MarketSummary]> = .idle
    var search: String = ""
    var sort: MarketSort = .priceDesc

    /// 401（未認証）を検知したときの再ログイン導線。RootView がサインアウト処理を注入する。
    var onUnauthorized: (() -> Void)?

    init(listMarketSummary: ListMarketSummary) {
        self.listMarketSummary = listMarketSummary
    }

    var visibleSummaries: [MarketSummary] {
        guard case let .loaded(summaries) = state else { return [] }
        return applyMarketQuery(summaries, search: search, sort: sort)
    }

    var overview: MarketOverview {
        guard case let .loaded(summaries) = state else {
            return MarketOverview(count: 0, topPrice: 0, avgPrice: 0, avgChange: 0)
        }
        return summarizeMarket(summaries)
    }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await listMarketSummary())
        } catch {
            if let apiError = error as? APIError, apiError == .unauthorized {
                onUnauthorized?()
            }
            state = .failed(error.localizedDescription)
        }
    }
}
