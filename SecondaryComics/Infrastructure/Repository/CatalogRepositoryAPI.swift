import Foundation
import SecondaryComicsCore

/// 実 API 版カタログリポジトリ。`GET /catalogs` を叩く。
/// レスポンスは `Catalog`（Codable）の配列で、プロパティ名は OpenAPI の項目名と一致するため
/// 追加のマッピングは不要。検索はクライアント側（Application 層）で行う。
struct CatalogRepositoryAPI: CatalogRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchCatalogs() async throws -> [Catalog] {
        try await client.get("/catalogs", as: [Catalog].self)
    }
}
