import Testing
@testable import Desafio

@MainActor
struct PreviewExchangesRepositoryTests {
    @Test
    func fetchExchangesReturnsPreviewData() async throws {
        let repository = PreviewExchangesRepository()

        let exchanges = try await repository.fetchExchanges()

        #expect(exchanges.isEmpty == false)
        #expect(exchanges.contains(where: { $0.name == "Mercado Bitcoin" }))
    }

    @Test
    func fetchExchangeDetailReturnsAssets() async throws {
        let repository = PreviewExchangesRepository()

        let detail = try await repository.fetchExchangeDetail(exchangeID: 270)

        #expect(detail.id == 270)
        #expect(detail.assets.isEmpty == false)
    }
}
