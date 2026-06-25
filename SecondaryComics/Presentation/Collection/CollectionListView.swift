import SwiftUI
import SecondaryComicsCore

/// ① マイコレクション一覧。
struct CollectionListView: View {
    @State private var model: CollectionListModel
    let imageBaseURL: String

    init(model: CollectionListModel, imageBaseURL: String) {
        _model = State(initialValue: model)
        self.imageBaseURL = imageBaseURL
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                content
            }
            .navigationTitle("マイコレクション")
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
            if model.visibleItems.isEmpty {
                EmptyStateView(
                    icon: "books.vertical",
                    title: "コレクションがありません",
                    message: "条件を変えるか、登録をお待ちください。"
                )
            } else {
                list
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: 12) {
                CollectionSummaryHeader(summary: model.summary)
                filterSortBar
                ForEach(model.visibleItems) { item in
                    NavigationLink {
                        CollectionDetailView(item: item, imageBaseURL: imageBaseURL)
                    } label: {
                        CollectionItemCard(item: item, imageBaseURL: imageBaseURL)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }

    private var filterSortBar: some View {
        HStack {
            Picker("フィルタ", selection: $model.filter) {
                ForEach(CollectionFilter.allCases, id: \.self) { Text($0.label).tag($0) }
            }
            Spacer()
            Picker("並び替え", selection: $model.sort) {
                ForEach(CollectionSort.allCases, id: \.self) { Text($0.label).tag($0) }
            }
        }
        .pickerStyle(.menu)
        .tint(Theme.accent2)
        .font(.subheadline)
    }
}

/// ヒーロー型サマリー。
private struct CollectionSummaryHeader: View {
    let summary: CollectionSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("現在評価額").font(.caption).foregroundStyle(Theme.muted)
            Text(Format.yen(summary.totalValue))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Theme.text)
            HStack(spacing: 16) {
                metric("含み損益", Format.signedYen(summary.pl), Theme.plColor(summary.pl))
                metric("総取得額", Format.yen(summary.totalCost), Theme.muted)
                metric("登録点数", "\(summary.count)", Theme.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: Theme.radius))
    }

    private func metric(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption2).foregroundStyle(Theme.muted)
            Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(color)
        }
    }
}

/// コレクション 1 行カード。
private struct CollectionItemCard: View {
    let item: CollectionItem
    let imageBaseURL: String

    var body: some View {
        HStack(spacing: 12) {
            RemoteImage(imageUrl: item.imageUrl, imageBaseURL: imageBaseURL)
                .frame(width: 56, height: 80)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.headline).foregroundStyle(Theme.text).lineLimit(1)
                Text("\(item.author)・\(item.volume)").font(.caption).foregroundStyle(Theme.muted).lineLimit(1)
                StateBadges(flags: item.flags, condition: item.condition)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(Format.yen(item.evaluation)).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                Text(Format.signedYen(item.profitLoss)).font(.caption).foregroundStyle(Theme.plColor(item.profitLoss))
            }
        }
        .padding(12)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: Theme.radius))
    }
}
