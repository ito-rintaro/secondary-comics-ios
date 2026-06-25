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

@Suite("Market summary")
struct MarketSummaryTests {
    @Test func summarizesRecords() {
        let records = [
            MarketRecord(id: "1", title: "A", price: 1000, change: 0.10),
            MarketRecord(id: "2", title: "B", price: 3000, change: 0.30),
            MarketRecord(id: "3", title: "C", price: 2000, change: -0.10)
        ]
        let s = summarizeMarket(records)
        #expect(s.count == 3)
        #expect(s.topPrice == 3000)
        #expect(s.avgPrice == 2000)                       // (1000+3000+2000)/3
        #expect(abs(s.avgChange - 0.10) < 1e-9)           // (0.10+0.30-0.10)/3
    }

    @Test func emptyIsAllZero() {
        let s = summarizeMarket([])
        #expect(s == MarketSummary(count: 0, topPrice: 0, avgPrice: 0, avgChange: 0))
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
