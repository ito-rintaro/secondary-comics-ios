import Foundation

/// コレクション取得・作成の port。Infrastructure 層で Impl（実 API）/ Demo（モック）を実装する。
public protocol CollectionRepository: Sendable {
    func fetchCollection() async throws -> [CollectionItem]
    /// 所有情報を送り、サーバが書誌・相場・id を合成した enriched な `CollectionItem` を受け取る。
    func createCollection(_ input: NewCollectionInput) async throws -> CollectionItem
}

/// マーケット相場取得の port。
/// 相場一覧カード・価格チャートは catalog 単位に集計された `MarketSummary`
/// （`GET /market/summary`）を供給源にする。
public protocol MarketRepository: Sendable {
    func fetchMarketSummary() async throws -> [MarketSummary]
}

/// カタログ（書誌マスタ）取得の port。全ユーザー共通（グローバル）。
public protocol CatalogRepository: Sendable {
    func fetchCatalogs() async throws -> [Catalog]
}
