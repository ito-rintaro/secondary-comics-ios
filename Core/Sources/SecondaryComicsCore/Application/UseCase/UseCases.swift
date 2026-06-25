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
