import SwiftUI
import SecondaryComicsCore

/// ③ マーケット一覧。
struct MarketListView: View {
    @State private var model: MarketListModel
    let imageBaseURL: String

    init(model: MarketListModel, imageBaseURL: String) {
        _model = State(initialValue: model)
        self.imageBaseURL = imageBaseURL
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                content
            }
            .navigationTitle("マーケット")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .searchable(text: $model.search, prompt: "作品名・著者・出版社")
        .task { if case .idle = model.state { await model.load() } }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .idle, .loading:
            ProgressView().tint(Theme.muted)
        case .failed(let message):
            ErrorStateView(message: message) { Task { await model.load() } }
        case .loaded:
            if model.visibleSummaries.isEmpty {
                EmptyStateView(icon: "chart.line.uptrend.xyaxis", title: "相場がありません", message: "条件を変えてみてください。")
            } else {
                list
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: 12) {
                MarketOverviewHeader(overview: model.overview)
                sortBar
                ForEach(model.visibleSummaries) { summary in
                    NavigationLink {
                        MarketDetailView(summary: summary, imageBaseURL: imageBaseURL)
                    } label: {
                        MarketSummaryCard(summary: summary, imageBaseURL: imageBaseURL)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }

    private var sortBar: some View {
        HStack {
            Spacer()
            Picker("並び替え", selection: $model.sort) {
                ForEach(MarketSort.allCases, id: \.self) { Text($0.label).tag($0) }
            }
            .pickerStyle(.menu)
            .tint(Theme.accent2)
            .font(.subheadline)
        }
    }
}

private struct MarketOverviewHeader: View {
    let overview: MarketOverview

    var body: some View {
        HStack(spacing: 12) {
            metric("銘柄数", "\(overview.count)", Theme.text)
            metric("最高額", Format.yen(overview.topPrice), Theme.text)
            metric("平均価格", Format.yen(Int(overview.avgPrice.rounded())), Theme.text)
            metric("平均値上り", Format.percent(overview.avgChange), Theme.changeColor(overview.avgChange))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: Theme.radius))
    }

    private func metric(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label).font(.caption2).foregroundStyle(Theme.muted)
            Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MarketSummaryCard: View {
    let summary: MarketSummary
    let imageBaseURL: String

    // 出品者・個別 condition は相場サマリ（catalog 単位）には無いため、書誌メタを見出しに使う。
    private var metaLine: String {
        [summary.author, summary.volume, summary.publisher]
            .filter { !$0.isEmpty }
            .joined(separator: " ・ ")
    }

    var body: some View {
        HStack(spacing: 12) {
            RemoteImage(imageUrl: summary.imageUrl, imageBaseURL: imageBaseURL)
                .frame(width: 48, height: 68)
            VStack(alignment: .leading, spacing: 4) {
                Text(summary.title).font(.headline).foregroundStyle(Theme.text).lineLimit(1)
                Text(metaLine).font(.caption).foregroundStyle(Theme.muted).lineLimit(1)
                StateBadges(flags: summary.flags)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Sparkline(history: summary.history, color: Theme.changeColor(summary.change))
                    .frame(width: 64, height: 28)
                Text(Format.yen(summary.price)).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                Text(Format.percent(summary.change)).font(.caption).foregroundStyle(Theme.changeColor(summary.change))
            }
        }
        .padding(12)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: Theme.radius))
    }
}
