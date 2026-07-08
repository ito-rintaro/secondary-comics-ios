import SwiftUI
import Charts
import SecondaryComicsCore

/// ④ 相場詳細（大きな 12ヶ月チャート、最安/最高/変動）。
struct MarketDetailView: View {
    let summary: MarketSummary
    let imageBaseURL: String

    // 書誌メタ（著者・巻数・出版社）。出品者・個別 condition は相場サマリには無い。
    private var metaLine: String {
        [summary.author, summary.volume, summary.publisher]
            .filter { !$0.isEmpty }
            .joined(separator: " ・ ")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    RemoteImage(imageUrl: summary.imageUrl, imageBaseURL: imageBaseURL)
                        .frame(width: 90, height: 128)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(summary.title).font(.title3.bold()).foregroundStyle(Theme.text)
                        Text(metaLine).font(.caption).foregroundStyle(Theme.muted)
                        StateBadges(flags: summary.flags)
                        Text("成約 \(summary.sampleCount) 件・最終 \(summary.lastSoldAt)")
                            .font(.caption2).foregroundStyle(Theme.muted)
                    }
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("現在価格").font(.caption).foregroundStyle(Theme.muted)
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(Format.yen(summary.price)).font(.system(size: 30, weight: .bold)).foregroundStyle(Theme.text)
                        Text(Format.percent(summary.change)).font(.headline).foregroundStyle(Theme.changeColor(summary.change))
                    }
                }

                chart

                HStack(spacing: 12) {
                    stat("最安", Format.yen(summary.history.min() ?? summary.price))
                    stat("最高", Format.yen(summary.history.max() ?? summary.price))
                    stat("12ヶ月変動", Format.percent(changeRate(summary.history)))
                }
            }
            .padding(16)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("相場詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var chart: some View {
        Chart(Array(summary.history.enumerated()), id: \.offset) { index, value in
            LineMark(x: .value("月", index + 1), y: .value("価格", value))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Theme.changeColor(summary.change))
            AreaMark(x: .value("月", index + 1), y: .value("価格", value))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Theme.changeColor(summary.change).opacity(0.12))
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(values: .stride(by: 3)) { _ in
                AxisGridLine().foregroundStyle(Theme.line)
                AxisValueLabel().foregroundStyle(Theme.muted)
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine().foregroundStyle(Theme.line)
                AxisValueLabel().foregroundStyle(Theme.muted)
            }
        }
        .padding(16)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: Theme.radius))
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(label).font(.caption2).foregroundStyle(Theme.muted)
            Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: Theme.radius))
    }
}
