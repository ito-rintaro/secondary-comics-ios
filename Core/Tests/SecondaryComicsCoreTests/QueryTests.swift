import Testing
@testable import SecondaryComicsCore

// クライアント側の検索・フィルタ・ソート。

private func sample() -> [CollectionItem] {
    [
        CollectionItem(id: "1", title: "ドラゴン伝説", author: "山田", qty: 1, cost: 1000, market: 2000,
                       flags: ConditionFlags(firstEd: true), updatedAt: 300),
        CollectionItem(id: "2", title: "海の歌", author: "鈴木", qty: 1, cost: 3000, market: 1000,
                       flags: ConditionFlags(obi: true), updatedAt: 100),
        CollectionItem(id: "3", title: "星のかけら", author: "山田", qty: 1, cost: 500, market: 500,
                       flags: ConditionFlags(special: true), updatedAt: 200)
    ]
}

@Suite("Collection query")
struct CollectionQueryTests {
    @Test func searchMatchesAuthor() {
        let r = applyCollectionQuery(sample(), search: "山田")
        #expect(r.map(\.id).sorted() == ["1", "3"])
    }

    @Test func filterProfitAndLoss() {
        #expect(applyCollectionQuery(sample(), filter: .profit).map(\.id) == ["1"])
        #expect(applyCollectionQuery(sample(), filter: .loss).map(\.id) == ["2"])
    }

    @Test func filterFlags() {
        #expect(applyCollectionQuery(sample(), filter: .firstEd).map(\.id) == ["1"])
        #expect(applyCollectionQuery(sample(), filter: .obi).map(\.id) == ["2"])
        #expect(applyCollectionQuery(sample(), filter: .special).map(\.id) == ["3"])
    }

    @Test func sortUpdatedIsDefaultDescending() {
        #expect(applyCollectionQuery(sample()).map(\.id) == ["1", "3", "2"]) // updatedAt 300,200,100
    }

    @Test func sortByProfitLossDesc() {
        // pl: 1=+1000, 2=-2000, 3=0
        #expect(applyCollectionQuery(sample(), sort: .plDesc).map(\.id) == ["1", "3", "2"])
    }
}

@Suite("Market query")
struct MarketQueryTests {
    private func summaries() -> [MarketSummary] {
        [
            MarketSummary(catalogId: "1", title: "A", author: "山田", price: 1000, change: 0.50, lastSoldAt: "2026-01-10"),
            MarketSummary(catalogId: "2", title: "B", author: "鈴木", price: 3000, change: 0.10, lastSoldAt: "2026-03-30"),
            MarketSummary(catalogId: "3", title: "C", author: "山田", price: 2000, change: 0.30, lastSoldAt: "2026-02-20")
        ]
    }

    @Test func sortPriceDescIsDefault() {
        #expect(applyMarketQuery(summaries()).map(\.id) == ["2", "3", "1"])
    }

    @Test func sortTrendDesc() {
        #expect(applyMarketQuery(summaries(), sort: .trendDesc).map(\.id) == ["1", "3", "2"])
    }

    @Test func sortRecentDesc() {
        #expect(applyMarketQuery(summaries(), sort: .recentDesc).map(\.id) == ["2", "3", "1"])
    }

    @Test func searchMatchesAuthor() {
        #expect(applyMarketQuery(summaries(), search: "山田").map(\.id).sorted() == ["1", "3"])
    }
}
