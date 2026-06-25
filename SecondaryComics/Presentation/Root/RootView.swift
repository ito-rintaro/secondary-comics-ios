import SwiftUI

/// ルート。TabView（マイコレクション / マーケット）。
/// MVP は Demo モードのため未ログインでも閲覧可。Phase 4 でログインゲートを RootView に追加する。
struct RootView: View {
    let container: AppContainer

    var body: some View {
        TabView {
            CollectionListView(
                model: CollectionListModel(listCollection: container.listCollection),
                imageBaseURL: container.config.imageBaseURL
            )
            .tabItem { Label("コレクション", systemImage: "books.vertical.fill") }

            MarketListView(
                model: MarketListModel(listMarket: container.listMarket),
                imageBaseURL: container.config.imageBaseURL
            )
            .tabItem { Label("マーケット", systemImage: "chart.line.uptrend.xyaxis") }
        }
        .tint(Theme.accent)
        .preferredColorScheme(.dark)
    }
}
