import Foundation

/// コレクション取得の port。Infrastructure 層で Impl（実 API）/ Demo（モック）を実装する。
public protocol CollectionRepository: Sendable {
    func fetchCollection() async throws -> [CollectionItem]
}

/// マーケット取得の port。
public protocol MarketRepository: Sendable {
    func fetchMarket() async throws -> [MarketRecord]
}
