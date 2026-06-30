import Foundation

/// コレクション一覧ユースケース。
public struct ListCollection: Sendable {
    private let repository: CollectionRepository
    public init(repository: CollectionRepository) {
        self.repository = repository
    }
    public func callAsFunction() async throws -> [CollectionItem] {
        try await repository.fetchCollection()
    }
}

/// コレクション新規登録ユースケース。
/// 所有情報（`NewCollectionInput`）を送り、サーバが合成した `CollectionItem` を返す。
public struct CreateCollection: Sendable {
    private let repository: CollectionRepository
    public init(repository: CollectionRepository) {
        self.repository = repository
    }
    public func callAsFunction(_ input: NewCollectionInput) async throws -> CollectionItem {
        try await repository.createCollection(input)
    }
}

/// カタログ（書誌マスタ）一覧ユースケース。
public struct ListCatalogs: Sendable {
    private let repository: CatalogRepository
    public init(repository: CatalogRepository) {
        self.repository = repository
    }
    public func callAsFunction() async throws -> [Catalog] {
        try await repository.fetchCatalogs()
    }
}

/// マーケット一覧ユースケース。
public struct ListMarket: Sendable {
    private let repository: MarketRepository
    public init(repository: MarketRepository) {
        self.repository = repository
    }
    public func callAsFunction() async throws -> [MarketRecord] {
        try await repository.fetchMarket()
    }
}
