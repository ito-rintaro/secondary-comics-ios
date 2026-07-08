import Foundation
import SecondaryComicsCore

/// 実 API 版マーケットリポジトリ。相場カード・チャートの供給源である
/// `GET /market/summary`（catalog 単位に集計された相場サマリ）を叩く。
/// マーケットは全ユーザー共通（グローバル）のため `sub` 絞り込みはサーバ側で行われない。
/// レスポンスは `MarketSummary`（Codable）の配列で、プロパティ名は OpenAPI の項目名と一致する。
struct MarketRepositoryAPI: MarketRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchMarketSummary() async throws -> [MarketSummary] {
        try await client.get("/market/summary", as: [MarketSummary].self)
    }
}
