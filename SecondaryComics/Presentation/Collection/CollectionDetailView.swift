import SwiftUI
import SecondaryComicsCore

/// 品詳細（push 遷移）。
struct CollectionDetailView: View {
    let item: CollectionItem
    let imageBaseURL: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    RemoteImage(imageUrl: item.imageUrl, imageBaseURL: imageBaseURL)
                        .frame(width: 110, height: 158)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title).font(.title3.bold()).foregroundStyle(Theme.text)
                        Text("\(item.author)").font(.subheadline).foregroundStyle(Theme.muted)
                        Text("\(item.publisher)・\(item.volume)・\(item.year)")
                            .font(.caption).foregroundStyle(Theme.muted)
                        StateBadges(flags: item.flags, condition: item.condition)
                    }
                    Spacer()
                }

                valuationPanel

                infoPanel
            }
            .padding(16)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var valuationPanel: some View {
        VStack(spacing: 10) {
            row("評価額", Format.yen(item.evaluation), Theme.text)
            row("取得額", Format.yen(item.acquisitionCost), Theme.muted)
            row("含み損益", Format.signedYen(item.profitLoss), Theme.plColor(item.profitLoss))
            Divider().overlay(Theme.line)
            row("現在相場（1点）", Format.yen(item.market), Theme.text)
            row("相場の鮮度", item.marketSource.label, Theme.muted)
            row("所有数", "\(item.qty)", Theme.muted)
        }
        .padding(16)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: Theme.radius))
    }

    private var infoPanel: some View {
        VStack(spacing: 10) {
            row("購入日", item.purchaseDate.isEmpty ? "—" : item.purchaseDate, Theme.muted)
            row("購入店", item.store.isEmpty ? "—" : item.store, Theme.muted)
            row("保管場所", item.location.isEmpty ? "—" : item.location, Theme.muted)
            if !item.memo.isEmpty { row("メモ", item.memo, Theme.muted) }
        }
        .padding(16)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: Theme.radius))
    }

    private func row(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(Theme.muted)
            Spacer()
            Text(value).font(.subheadline.weight(.medium)).foregroundStyle(color)
        }
    }
}
