import SwiftUI
import SecondaryComicsCore

/// ルート。TabView（マイコレクション / マーケット）。
/// サインイン後にのみ表示される（出し分けは `SecondaryComicsApp` の認証ゲート）。
/// 401 を検知したら ViewModel 経由で再ログイン画面へ戻す。
struct RootView: View {
    @State private var collectionModel: CollectionListModel
    @State private var marketModel: MarketListModel
    private let imageBaseURL: String
    private let authModel: AuthViewModel
    private let listCatalogs: ListCatalogs
    private let createCollection: CreateCollection

    init(container: AppContainer, authModel: AuthViewModel) {
        self.imageBaseURL = container.config.imageBaseURL
        self.authModel = authModel
        self.listCatalogs = container.listCatalogs
        self.createCollection = container.createCollection

        let collection = CollectionListModel(listCollection: container.listCollection)
        let market = MarketListModel(listMarket: container.listMarket)
        // 401 → 強制サインアウト（ログイン画面へ）。
        collection.onUnauthorized = { authModel.forceSignedOut() }
        market.onUnauthorized = { authModel.forceSignedOut() }
        _collectionModel = State(initialValue: collection)
        _marketModel = State(initialValue: market)
    }

    /// 登録モーダル用 ViewModel を生成（401 導線を注入）。
    private func makeAddModel() -> AddCollectionModel {
        let add = AddCollectionModel(listCatalogs: listCatalogs, createCollection: createCollection)
        add.onUnauthorized = { authModel.forceSignedOut() }
        return add
    }

    var body: some View {
        TabView {
            CollectionListView(
                model: collectionModel,
                imageBaseURL: imageBaseURL,
                onSignOut: { Task { await authModel.signOut() } },
                makeAddModel: makeAddModel
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
