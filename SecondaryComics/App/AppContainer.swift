import Foundation
import SecondaryComicsCore

/// DI コンテナ。`config.useAPI` で Repository / 認証の Demo ↔ 実 API を切り替える。
/// - useAPI = true  : Amplify(Cognito) 認証 + `*RepositoryAPI`（`GET /collection` `GET /market/summary`）
/// - useAPI = false : `StubAuthService`（ログイン素通り）+ `*RepositoryDemo`（モックデータ）
@MainActor
final class AppContainer {
    let config: AppConfig
    let collectionRepository: CollectionRepository
    let marketRepository: MarketRepository
    let catalogRepository: CatalogRepository
    let authService: AuthService

    init(
        config: AppConfig,
        collectionRepository: CollectionRepository,
        marketRepository: MarketRepository,
        catalogRepository: CatalogRepository,
        authService: AuthService
    ) {
        self.config = config
        self.collectionRepository = collectionRepository
        self.marketRepository = marketRepository
        self.catalogRepository = catalogRepository
        self.authService = authService
    }

    /// `config` から実 API / Demo の依存を組み立てる既定のファクトリ。
    /// 既定はビルド構成依存の `AppConfig.current`（Debug→dev / Release→prod）。
    convenience init(config: AppConfig = .current) {
        if config.useAPI, let baseURL = URL(string: config.apiBaseURL) {
            let client = APIClient(baseURL: baseURL, tokenProvider: AmplifyTokenProvider())
            self.init(
                config: config,
                collectionRepository: CollectionRepositoryAPI(client: client),
                marketRepository: MarketRepositoryAPI(client: client),
                catalogRepository: CatalogRepositoryAPI(client: client),
                authService: AmplifyAuthService()
            )
        } else {
            self.init(
                config: config,
                collectionRepository: CollectionRepositoryDemo(),
                marketRepository: MarketRepositoryDemo(),
                catalogRepository: CatalogRepositoryDemo(),
                authService: StubAuthService()
            )
        }
    }

    var listCollection: ListCollection { ListCollection(repository: collectionRepository) }
    var createCollection: CreateCollection { CreateCollection(repository: collectionRepository) }
    var listMarketSummary: ListMarketSummary { ListMarketSummary(repository: marketRepository) }
    var listCatalogs: ListCatalogs { ListCatalogs(repository: catalogRepository) }
}
