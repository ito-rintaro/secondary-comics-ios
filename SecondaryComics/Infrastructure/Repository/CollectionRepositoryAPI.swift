import Foundation
import SecondaryComicsCore

/// 実 API 版コレクションリポジトリ。`GET /collection` を叩く。
/// レスポンスは `CollectionItem`（Codable）の配列で、プロパティ名は OpenAPI の項目名と一致するため
/// 追加のマッピングは不要。検索 / フィルタ / ソート / 集計はクライアント側（Application 層）で行う。
struct CollectionRepositoryAPI: CollectionRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchCollection() async throws -> [CollectionItem] {
        try await client.get("/collection", as: [CollectionItem].self)
    }
}
