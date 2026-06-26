import Foundation
import SecondaryComicsCore

/// 実 API 版マーケットリポジトリ。`GET /market` を叩く。
/// マーケットは全ユーザー共通（グローバル）のため `sub` 絞り込みはサーバ側で行われない。
/// レスポンスは `MarketRecord`（Codable）の配列で、プロパティ名は OpenAPI の項目名と一致する。
struct MarketRepositoryAPI: MarketRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchMarket() async throws -> [MarketRecord] {
        try await client.get("/market", as: [MarketRecord].self)
    }
}
