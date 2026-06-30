import Foundation
import SecondaryComicsCore

/// 実 API 版コレクションリポジトリ。`GET /collection`（一覧）と `POST /collection`（新規登録）を叩く。
/// レスポンスは `CollectionItem`（Codable）で、プロパティ名は OpenAPI の項目名と一致するため
/// 追加のマッピングは不要。検索 / フィルタ / ソート / 集計はクライアント側（Application 層）で行う。
struct CollectionRepositoryAPI: CollectionRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchCollection() async throws -> [CollectionItem] {
        try await client.get("/collection", as: [CollectionItem].self)
    }

    func createCollection(_ input: NewCollectionInput) async throws -> CollectionItem {
        // 201 で enriched な CollectionItem（書誌・相場・id 合成済み）が返る。
        try await client.post("/collection", body: input, as: CollectionItem.self)
    }
}
