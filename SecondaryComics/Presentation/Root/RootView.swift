import SwiftUI

/// ルート。TabView（マイコレクション / マーケット）。
/// サインイン後にのみ表示される（出し分けは `SecondaryComicsApp` の認証ゲート）。
/// 401 を検知したら ViewModel 経由で再ログイン画面へ戻す。
struct RootView: View {
    @State private var collectionModel: CollectionListModel
    @State private var marketModel: MarketListModel
    private let imageBaseURL: String
    private let authModel: AuthViewModel

    init(container: AppContainer, authModel: AuthViewModel) {
        self.imageBaseURL = container.config.imageBaseURL
        self.authModel = authModel

        let collection = CollectionListModel(listCollection: container.listCollection)
        let market = MarketListModel(listMarket: container.listMarket)
        // 401 → 強制サインアウト（ログイン画面へ）。
        collection.onUnauthorized = { authModel.forceSignedOut() }
        market.onUnauthorized = { authModel.forceSignedOut() }
        _collectionModel = State(initialValue: collection)
        _marketModel = State(initialValue: market)
    }

    var body: some View {
        TabView {
            CollectionListView(
                model: collectionModel,
                imageBaseURL: imageBaseURL,
                onSignOut: { Task { await authModel.signOut() } }
            )
            .tabItem { Label("コレクション", systemImage: "books.vertical.fill") }

            MarketListView(
                model: marketModel,
                imageBaseURL: imageBaseURL
            )
            .tabItem { Label("マーケット", systemImage: "chart.line.uptrend.xyaxis") }
        }
        .tint(Theme.accent)
        .preferredColorScheme(.dark)
    }
}
