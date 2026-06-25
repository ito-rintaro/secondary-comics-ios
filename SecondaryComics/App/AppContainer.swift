import Foundation
import SecondaryComicsCore

/// DI コンテナ。Repository の Demo ↔ Impl 差し替えの中心。
/// MVP は Demo を注入。Phase 4 で Impl（実 API + Cognito）に差し替える。
@MainActor
final class AppContainer {
    let config: AppConfig
    let collectionRepository: CollectionRepository
    let marketRepository: MarketRepository

    init(
        config: AppConfig = .placeholder,
        collectionRepository: CollectionRepository = CollectionRepositoryDemo(),
        marketRepository: MarketRepository = MarketRepositoryDemo()
    ) {
        self.config = config
        self.collectionRepository = collectionRepository
        self.marketRepository = marketRepository
    }

    var listCollection: ListCollection { ListCollection(repository: collectionRepository) }
    var listMarket: ListMarket { ListMarket(repository: marketRepository) }
}
