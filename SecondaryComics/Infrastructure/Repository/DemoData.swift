import Foundation
import SecondaryComicsCore

/// プレビュー / 開発用のモックデータ。実 API 不在でも画面を完成させるため。
enum DemoData {
    static let collection: [CollectionItem] = [
        CollectionItem(
            id: "c1", title: "鋼の錬金術師", author: "荒川弘", publisher: "スクウェア・エニックス",
            volume: "全27巻", year: "2002", condition: .s, qty: 1, cost: 12000, market: 18000,
            marketSource: .manual, flags: ConditionFlags(firstEd: true, obi: true),
            purchaseDate: "2021-05-10", store: "まんだらけ", location: "書斎A棚",
            updatedAt: 1_717_200_000_000
        ),
        CollectionItem(
            id: "c2", title: "AKIRA", author: "大友克洋", publisher: "講談社",
            volume: "全6巻", year: "1984", condition: .a, qty: 1, cost: 25000, market: 42000,
            marketSource: .manual, flags: ConditionFlags(firstEd: true),
            purchaseDate: "2020-11-02", store: "ヤフオク", location: "書斎B棚",
            updatedAt: 1_717_100_000_000
        ),
        CollectionItem(
            id: "c3", title: "ドラゴンボール", author: "鳥山明", publisher: "集英社",
            volume: "全42巻", year: "1985", condition: .b, qty: 1, cost: 30000, market: 28000,
            marketSource: .estimate, flags: ConditionFlags(),
            purchaseDate: "2019-03-20", store: "ブックオフ", location: "押入れ",
            updatedAt: 1_716_900_000_000
        ),
        CollectionItem(
            id: "c4", title: "SLAM DUNK", author: "井上雄彦", publisher: "集英社",
            volume: "全31巻", year: "1990", condition: .a, qty: 2, cost: 8000, market: 9500,
            marketSource: .manual, flags: ConditionFlags(special: true),
            purchaseDate: "2022-01-15", store: "駿河屋", location: "書斎A棚",
            updatedAt: 1_717_000_000_000
        )
    ]

    static let catalogs: [Catalog] = [
        Catalog(
            id: "cat-001", title: "鋼の錬金術師", author: "荒川弘",
            publisher: "スクウェア・エニックス", volume: "全27巻", year: "2002",
            flags: ConditionFlags(firstEd: true, obi: true)
        ),
        Catalog(
            id: "cat-002", title: "AKIRA", author: "大友克洋",
            publisher: "講談社", volume: "全6巻", year: "1984",
            flags: ConditionFlags(firstEd: true)
        ),
        Catalog(
            id: "cat-003", title: "ドラゴンボール", author: "鳥山明",
            publisher: "集英社", volume: "全42巻", year: "1985",
            flags: ConditionFlags()
        ),
        Catalog(
            id: "cat-004", title: "SLAM DUNK", author: "井上雄彦",
            publisher: "集英社", volume: "全31巻", year: "1990",
            flags: ConditionFlags(special: true)
        )
    ]

    static let market: [MarketRecord] = [
        MarketRecord(
            id: "m1", title: "AKIRA", author: "大友克洋", publisher: "講談社", volume: "全6巻",
            seller: "古書つかさ", condition: .s, flags: ConditionFlags(firstEd: true, obi: true),
            history: [38000, 38500, 39000, 39500, 40000, 40500, 41000, 41200, 41500, 41800, 42500, 44000],
            price: 44000, change: changeRate([38000, 44000]), listedAt: 1050
        ),
        MarketRecord(
            id: "m2", title: "鋼の錬金術師", author: "荒川弘", publisher: "スクウェア・エニックス", volume: "全27巻",
            seller: "まんだらけ", condition: .a, flags: ConditionFlags(firstEd: true),
            history: [16000, 16200, 16500, 16800, 17000, 17200, 17500, 17800, 18000, 18200, 18500, 18800],
            price: 18800, change: changeRate([16000, 18800]), listedAt: 1040
        ),
        MarketRecord(
            id: "m3", title: "ドラゴンボール", author: "鳥山明", publisher: "集英社", volume: "全42巻",
            seller: "駿河屋", condition: .b, flags: ConditionFlags(),
            history: [32000, 31500, 31000, 30500, 30000, 29500, 29000, 28800, 28500, 28200, 28000, 27500],
            price: 27500, change: changeRate([32000, 27500]), listedAt: 1030
        )
    ]
}

/// 遅延を模した Demo リポジトリ（Demo ↔ Impl を DI で差し替え）。
/// 新規登録を擬似的に永続化するため actor で可変リストを保持する
/// （登録した直後の一覧再取得に反映させる）。
actor CollectionRepositoryDemo: CollectionRepository {
    private var items: [CollectionItem] = DemoData.collection

    func fetchCollection() async throws -> [CollectionItem] {
        try? await Task.sleep(for: .milliseconds(300))
        return items
    }

    func createCollection(_ input: NewCollectionInput) async throws -> CollectionItem {
        try? await Task.sleep(for: .milliseconds(300))
        // サーバの enrich を模す: カタログ由来の書誌を合成し、id / updatedAt を採番する。
        let catalog = DemoData.catalogs.first { $0.id == input.catalogId }
        let item = CollectionItem(
            id: "demo-\(items.count + 1)",
            title: catalog?.title ?? "（不明なカタログ）",
            author: catalog?.author ?? "",
            publisher: catalog?.publisher ?? "",
            volume: catalog?.volume ?? "",
            year: catalog?.year ?? "",
            condition: input.condition,
            qty: input.qty,
            cost: input.cost,
            market: 0,
            marketSource: .estimate,
            flags: catalog?.flags ?? ConditionFlags(),
            purchaseDate: input.purchaseDate,
            store: input.store,
            location: input.location,
            memo: input.memo,
            imageUrl: catalog?.imageUrl ?? "",
            updatedAt: Int64(Date().timeIntervalSince1970 * 1000)
        )
        items.insert(item, at: 0)
        return item
    }
}

struct CatalogRepositoryDemo: CatalogRepository {
    func fetchCatalogs() async throws -> [Catalog] {
        try? await Task.sleep(for: .milliseconds(300))
        return DemoData.catalogs
    }
}

struct MarketRepositoryDemo: MarketRepository {
    func fetchMarket() async throws -> [MarketRecord] {
        try? await Task.sleep(for: .milliseconds(300))
        return DemoData.market
    }
}
