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
        .searchable(text: $model.search, prompt: "作品名・著者・ショップ")
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
            if model.visibleRecords.isEmpty {
                EmptyStateView(icon: "chart.line.uptrend.xyaxis", title: "相場がありません", message: "条件を変えてみてください。")
            } else {
                list
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: 12) {
                MarketSummaryHeader(summary: model.summary)
                sortBar
                ForEach(model.visibleRecords) { record in
                    NavigationLink {
                        MarketDetailView(record: record, imageBaseURL: imageBaseURL)
                    } label: {
                        MarketRecordCard(record: record, imageBaseURL: imageBaseURL)
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

private struct MarketSummaryHeader: View {
    let summary: MarketSummary

    var body: some View {
        HStack(spacing: 12) {
            metric("出品数", "\(summary.count)", Theme.text)
            metric("最高額", Format.yen(summary.topPrice), Theme.text)
            metric("平均価格", Format.yen(Int(summary.avgPrice.rounded())), Theme.text)
            metric("平均値上り", Format.percent(summary.avgChange), Theme.changeColor(summary.avgChange))
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

private struct MarketRecordCard: View {
    let record: MarketRecord
    let imageBaseURL: String

    var body: some View {
        HStack(spacing: 12) {
            RemoteImage(imageUrl: record.imageUrl, imageBaseURL: imageBaseURL)
                .frame(width: 48, height: 68)
            VStack(alignment: .leading, spacing: 4) {
                Text(record.title).font(.headline).foregroundStyle(Theme.text).lineLimit(1)
                Text(record.seller).font(.caption).foregroundStyle(Theme.muted).lineLimit(1)
                StateBadges(flags: record.flags, condition: record.condition)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Sparkline(history: record.history, color: Theme.changeColor(record.change))
                    .frame(width: 64, height: 28)
                Text(Format.yen(record.price)).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                Text(Format.percent(record.change)).font(.caption).foregroundStyle(Theme.changeColor(record.change))
            }
        }
        .padding(12)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: Theme.radius))
    }
}
