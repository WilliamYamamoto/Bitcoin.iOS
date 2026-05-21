import Foundation

struct AppContainer {
    let exchangesRepository: ExchangesRepository

    static func makeDefault() -> AppContainer {
        switch AppLaunchScenario.current() {
        case .live:
            let config = AppConfig.load()
            let httpClient = URLSessionHTTPClient(session: .shared)
            let service = CoinMarketCapExchangeService(httpClient: httpClient, config: config)
            let repository = LiveExchangesRepository(service: service)
            return AppContainer(exchangesRepository: repository)
        case .uiSuccess:
            return AppContainer(exchangesRepository: PreviewExchangesRepository())
        case .uiEmpty:
            return AppContainer(exchangesRepository: StubExchangesRepository(scenario: .empty))
        case .uiError:
            return AppContainer(exchangesRepository: StubExchangesRepository(scenario: .error(.offline)))
        case .uiRateLimit:
            return AppContainer(exchangesRepository: StubExchangesRepository(scenario: .error(.rateLimited)))
        }
    }

    static let preview = AppContainer(exchangesRepository: PreviewExchangesRepository())

    func makeExchangesListViewModel() -> ExchangesListViewModel {
        ExchangesListViewModel(repository: exchangesRepository)
    }

    func makeExchangeDetailViewModel(exchangeID: Int) -> ExchangeDetailViewModel {
        ExchangeDetailViewModel(exchangeID: exchangeID, repository: exchangesRepository)
    }
}

private struct StubExchangesRepository: ExchangesRepository {
    enum Scenario {
        case empty
        case error(NetworkError)
    }

    let scenario: Scenario

    func fetchExchanges() async throws -> [ExchangeSummary] {
        switch scenario {
        case .empty:
            return []
        case .error(let error):
            throw error
        }
    }

    func fetchExchangeDetail(exchangeID: Int) async throws -> ExchangeDetail {
        switch scenario {
        case .empty:
            return ExchangeDetail(
                id: exchangeID,
                name: "Exchange sem assets",
                logoURL: nil,
                description: "Stub usado para testes de UI.",
                websiteURL: nil,
                makerFee: nil,
                takerFee: nil,
                dateLaunched: nil,
                assets: []
            )
        case .error(let error):
            throw error
        }
    }
}
