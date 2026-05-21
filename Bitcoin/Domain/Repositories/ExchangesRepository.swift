import Foundation

protocol ExchangesRepository: Sendable {
    func fetchExchanges() async throws -> [ExchangeSummary]
    func fetchExchangeDetail(exchangeID: Int) async throws -> ExchangeDetail
}
