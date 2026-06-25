import SwiftUI
import Charts
import SecondaryComicsCore

/// 12ヶ月スパークライン（Swift Charts の LineMark）。
struct Sparkline: View {
    let history: [Int]
    var color: Color = Theme.accent2

    var body: some View {
        Chart(Array(history.enumerated()), id: \.offset) { index, value in
            LineMark(x: .value("月", index), y: .value("価格", value))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(color)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: yDomain)
    }

    private var yDomain: ClosedRange<Int> {
        guard let lo = history.min(), let hi = history.max(), lo != hi else {
            return 0...max(1, history.first ?? 1)
        }
        let pad = max(1, (hi - lo) / 10)
        return (lo - pad)...(hi + pad)
    }
}
