import SwiftUI
import Charts
import SecondaryComicsCore

/// ④ 相場詳細（大きな 12ヶ月チャート、最安/最高/変動）。
struct MarketDetailView: View {
    let record: MarketRecord
    let imageBaseURL: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    RemoteImage(imageUrl: record.imageUrl, imageBaseURL: imageBaseURL)
                        .frame(width: 90, height: 128)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(record.title).font(.title3.bold()).foregroundStyle(Theme.text)
                        Text("\(record.author)・\(record.volume)").font(.caption).foregroundStyle(Theme.muted)
                        Text(record.seller).font(.caption).foregroundStyle(Theme.muted)
                        StateBadges(flags: record.flags, condition: record.condition)
                    }
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("現在価格").font(.caption).foregroundStyle(Theme.muted)
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(Format.yen(record.price)).font(.system(size: 30, weight: .bold)).foregroundStyle(Theme.text)
                        Text(Format.percent(record.change)).font(.headline).foregroundStyle(Theme.changeColor(record.change))
                    }
                }

                chart

                HStack(spacing: 12) {
                    stat("最安", Format.yen(record.history.min() ?? record.price))
                    stat("最高", Format.yen(record.history.max() ?? record.price))
                    stat("12ヶ月変動", Format.percent(changeRate(record.history)))
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
        Chart(Array(record.history.enumerated()), id: \.offset) { index, value in
            LineMark(x: .value("月", index + 1), y: .value("価格", value))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Theme.changeColor(record.change))
            AreaMark(x: .value("月", index + 1), y: .value("価格", value))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Theme.changeColor(record.change).opacity(0.12))
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
