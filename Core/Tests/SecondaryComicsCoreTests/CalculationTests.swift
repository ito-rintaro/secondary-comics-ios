import Foundation
import Testing
@testable import SecondaryComicsCore

// 計算式が「正」。ここで数式を固定する。

@Suite("Item calculations")
struct ItemCalculationTests {
    @Test func profitLossEvaluationAcquisition() {
        let it = CollectionItem(id: "1", title: "X", qty: 3, cost: 1000, market: 1500)
        #expect(it.profitLoss == (1500 - 1000) * 3)      // 1500
        #expect(it.evaluation == 1500 * 3)               // 4500
        #expect(it.acquisitionCost == 1000 * 3)          // 3000
    }

    @Test func negativeProfitLoss() {
        let it = CollectionItem(id: "1", title: "X", qty: 2, cost: 2000, market: 1200)
        #expect(it.profitLoss == (1200 - 2000) * 2)      // -1600
    }
}

@Suite("Collection summary")
struct CollectionSummaryTests {
    @Test func summarizesMultipleItems() {
        let items = [
            CollectionItem(id: "1", title: "A", qty: 2, cost: 1000, market: 1500),
            CollectionItem(id: "2", title: "B", qty: 1, cost: 5000, market: 4000)
        ]
        let s = summarize(items)
        #expect(s.count == 3)            // 2 + 1
        #expect(s.totalCost == 2000 + 5000)   // 7000
        #expect(s.totalValue == 3000 + 4000)  // 7000
        #expect(s.pl == s.totalValue - s.totalCost) // 0
    }

    @Test func emptyIsAllZero() {
        let s = summarize([])
        #expect(s == CollectionSummary(count: 0, totalCost: 0, totalValue: 0, pl: 0))
    }
}

@Suite("Market overview")
struct MarketOverviewTests {
    @Test func summarizesSummaries() {
        let summaries = [
            MarketSummary(catalogId: "cat-1", title: "A", price: 1000, change: 0.10),
            MarketSummary(catalogId: "cat-2", title: "B", price: 3000, change: 0.30),
            MarketSummary(catalogId: "cat-3", title: "C", price: 2000, change: -0.10)
        ]
        let s = summarizeMarket(summaries)
        #expect(s.count == 3)
        #expect(s.topPrice == 3000)
        #expect(s.avgPrice == 2000)                       // (1000+3000+2000)/3
        #expect(abs(s.avgChange - 0.10) < 1e-9)           // (0.10+0.30-0.10)/3
    }

    @Test func emptyIsAllZero() {
        let s = summarizeMarket([])
        #expect(s == MarketOverview(count: 0, topPrice: 0, avgPrice: 0, avgChange: 0))
    }
}

@Suite("Market summary fold")
struct MarketSummaryFoldTests {
    // 2026-07 を当月基準にする（history 末尾＝当月バケット）。
    private var asOf: Date {
        var c = DateComponents()
        c.year = 2026; c.month = 7; c.day = 15
        return Calendar(identifier: .gregorian).date(from: c)!
    }

    private func sale(_ catalog: String, _ price: Int, _ soldAt: String) -> MarketSale {
        MarketSale(id: "\(catalog)-\(soldAt)", title: "T-\(catalog)", catalogId: catalog, price: price, soldAt: soldAt)
    }

    @Test func groupsByCatalogAndDerivesPriceChangeHistory() {
        // cat-A: 2026-05 に 10000、2026-07 に 12000。間の 06 月は前方フィル(10000)。
        let summaries = deriveMarketSummaries(
            from: [sale("cat-A", 10000, "2026-05-10"), sale("cat-A", 12000, "2026-07-01")],
            asOf: asOf
        )
        #expect(summaries.count == 1)
        let s = summaries[0]
        #expect(s.catalogId == "cat-A")
        #expect(s.history.count == 12)
        #expect(s.price == 12000)                 // 末尾＝当月(2026-07)
        #expect(s.history[9] == 10000)            // 2026-05（末尾から2つ前）
        #expect(s.history[10] == 10000)           // 2026-06 は前方フィル
        #expect(s.history[11] == 12000)           // 2026-07
        #expect(s.sampleCount == 2)
        #expect(s.lastSoldAt == "2026-07-01")
        #expect(abs(s.change - 0.20) < 1e-9)      // (12000-10000)/10000
    }

    @Test func backfillsBeforeFirstSaleAndAveragesWithinMonth() {
        // 当月(2026-07)に 2 件 → 平均。それ以前は全て backfill で同値。
        let summaries = deriveMarketSummaries(
            from: [sale("cat-B", 20000, "2026-07-02"), sale("cat-B", 24000, "2026-07-20")],
            asOf: asOf
        )
        let s = summaries[0]
        #expect(s.history.allSatisfy { $0 == 22000 })  // 平均 22000 が全月に backfill
        #expect(s.change == 0)                          // 先頭＝末尾
        #expect(s.price == 22000)
    }

    @Test func excludesCatalogsWithNoSales() {
        #expect(deriveMarketSummaries(from: [], asOf: asOf).isEmpty)
    }

    @Test func preservesFirstSeenCatalogOrder() {
        let summaries = deriveMarketSummaries(
            from: [sale("cat-Z", 100, "2026-07-01"), sale("cat-A", 200, "2026-07-01"), sale("cat-Z", 150, "2026-06-01")],
            asOf: asOf
        )
        #expect(summaries.map(\.catalogId) == ["cat-Z", "cat-A"])
    }
}

@Suite("changeRate")
struct ChangeRateTests {
    @Test func computesRate() {
        // 先頭 1000 → 末尾 1180 で +18%
        let h = [1000, 1050, 1100, 1120, 1130, 1140, 1150, 1155, 1160, 1170, 1175, 1180]
        #expect(abs(changeRate(h) - 0.18) < 1e-9)
    }

    @Test func emptyReturnsZero() {
        #expect(changeRate([]) == 0)
    }

    @Test func firstZeroReturnsZero() {
        #expect(changeRate([0, 100, 200]) == 0)
    }
}
