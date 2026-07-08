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

    /// 成約ログ（1 レコード = 1 価格）。相場サマリはこれを畳み込んで導出する（`deriveMarketSummaries`）。
    /// 書誌は catalog（cat-001/002/003）由来。日付は直近 1 年に散らしてチャートが成立するようにしている。
    static let marketSales: [MarketSale] = [
        // AKIRA（cat-002）: 上昇トレンド
        MarketSale(id: "mk-a1", title: "AKIRA", author: "大友克洋", publisher: "講談社", volume: "全6巻",
                   flags: ConditionFlags(firstEd: true), catalogId: "cat-002", condition: .a, price: 38000, soldAt: "2025-09-14", seller: "古書つかさ"),
        MarketSale(id: "mk-a2", title: "AKIRA", author: "大友克洋", publisher: "講談社", volume: "全6巻",
                   flags: ConditionFlags(firstEd: true), catalogId: "cat-002", condition: .a, price: 39000, soldAt: "2025-11-20", seller: "まんだらけ"),
        MarketSale(id: "mk-a3", title: "AKIRA", author: "大友克洋", publisher: "講談社", volume: "全6巻",
                   flags: ConditionFlags(firstEd: true), catalogId: "cat-002", condition: .s, price: 40000, soldAt: "2026-01-08", seller: "ヤフオク"),
        MarketSale(id: "mk-a4", title: "AKIRA", author: "大友克洋", publisher: "講談社", volume: "全6巻",
                   flags: ConditionFlags(firstEd: true), catalogId: "cat-002", condition: .a, price: 41000, soldAt: "2026-03-15", seller: "駿河屋"),
        MarketSale(id: "mk-a5", title: "AKIRA", author: "大友克洋", publisher: "講談社", volume: "全6巻",
                   flags: ConditionFlags(firstEd: true), catalogId: "cat-002", condition: .s, price: 42500, soldAt: "2026-05-02", seller: "古書つかさ"),
        MarketSale(id: "mk-a6", title: "AKIRA", author: "大友克洋", publisher: "講談社", volume: "全6巻",
                   flags: ConditionFlags(firstEd: true), catalogId: "cat-002", condition: .s, price: 44000, soldAt: "2026-07-05", seller: "コレクター田中"),

        // 鋼の錬金術師（cat-001）: 緩やかな上昇
        MarketSale(id: "mk-h1", title: "鋼の錬金術師", author: "荒川弘", publisher: "スクウェア・エニックス", volume: "全27巻",
                   flags: ConditionFlags(firstEd: true, obi: true), catalogId: "cat-001", condition: .a, price: 16000, soldAt: "2025-08-30", seller: "まんだらけ"),
        MarketSale(id: "mk-h2", title: "鋼の錬金術師", author: "荒川弘", publisher: "スクウェア・エニックス", volume: "全27巻",
                   flags: ConditionFlags(firstEd: true, obi: true), catalogId: "cat-001", condition: .a, price: 16500, soldAt: "2025-10-12", seller: "駿河屋"),
        MarketSale(id: "mk-h3", title: "鋼の錬金術師", author: "荒川弘", publisher: "スクウェア・エニックス", volume: "全27巻",
                   flags: ConditionFlags(firstEd: true, obi: true), catalogId: "cat-001", condition: .s, price: 17200, soldAt: "2025-12-25", seller: "ブックオフ"),
        MarketSale(id: "mk-h4", title: "鋼の錬金術師", author: "荒川弘", publisher: "スクウェア・エニックス", volume: "全27巻",
                   flags: ConditionFlags(firstEd: true, obi: true), catalogId: "cat-001", condition: .a, price: 17800, soldAt: "2026-02-18", seller: "まんだらけ"),
        MarketSale(id: "mk-h5", title: "鋼の錬金術師", author: "荒川弘", publisher: "スクウェア・エニックス", volume: "全27巻",
                   flags: ConditionFlags(firstEd: true, obi: true), catalogId: "cat-001", condition: .s, price: 18800, soldAt: "2026-06-22", seller: "古書つかさ"),

        // ドラゴンボール（cat-003）: 下降トレンド
        MarketSale(id: "mk-d1", title: "ドラゴンボール", author: "鳥山明", publisher: "集英社", volume: "全42巻",
                   flags: ConditionFlags(), catalogId: "cat-003", condition: .b, price: 32000, soldAt: "2025-08-05", seller: "駿河屋"),
        MarketSale(id: "mk-d2", title: "ドラゴンボール", author: "鳥山明", publisher: "集英社", volume: "全42巻",
                   flags: ConditionFlags(), catalogId: "cat-003", condition: .b, price: 31000, soldAt: "2025-10-01", seller: "ヤフオク"),
        MarketSale(id: "mk-d3", title: "ドラゴンボール", author: "鳥山明", publisher: "集英社", volume: "全42巻",
                   flags: ConditionFlags(), catalogId: "cat-003", condition: .c, price: 30000, soldAt: "2025-12-11", seller: "ブックオフ"),
        MarketSale(id: "mk-d4", title: "ドラゴンボール", author: "鳥山明", publisher: "集英社", volume: "全42巻",
                   flags: ConditionFlags(), catalogId: "cat-003", condition: .b, price: 28200, soldAt: "2026-04-19", seller: "駿河屋"),
        MarketSale(id: "mk-d5", title: "ドラゴンボール", author: "鳥山明", publisher: "集英社", volume: "全42巻",
                   flags: ConditionFlags(), catalogId: "cat-003", condition: .b, price: 27500, soldAt: "2026-06-15", seller: "まんだらけ")
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
    func fetchMarketSummary() async throws -> [MarketSummary] {
        try? await Task.sleep(for: .milliseconds(300))
        // サーバの集計を模し、成約ログを catalog 単位のサマリへ畳み込む。
        return deriveMarketSummaries(from: DemoData.marketSales)
    }
}
