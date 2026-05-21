import Foundation
import Testing
@testable import Desafio

@MainActor
struct LiveExchangesRepositoryTests {
    @Test
    func fetchExchangesMapsAndSortsBySpotVolumeDescending() async throws {
        let service = ExchangeServiceFake(
            listings: [
                ExchangeListingDTO(
                    id: 1,
                    name: "Low Volume",
                    slug: "low",
                    numMarketPairs: nil,
                    dateLaunched: nil,
                    quote: ["USD": ExchangeVolumeQuoteDTO(volume24h: 10, volume24hAdjusted: nil, effectiveLiquidity24h: nil, lastUpdated: nil)],
                    lastUpdated: nil
                ),
                ExchangeListingDTO(
                    id: 2,
                    name: "High Volume",
                    slug: "high",
                    numMarketPairs: nil,
                    dateLaunched: nil,
                    quote: ["USD": ExchangeVolumeQuoteDTO(volume24h: 20, volume24hAdjusted: nil, effectiveLiquidity24h: nil, lastUpdated: nil)],
                    lastUpdated: nil
                )
            ],
            info: [
                1: ExchangeInfoDTO(id: 1, name: "Low Volume", slug: "low", logo: nil, description: nil, dateLaunched: nil, makerFee: nil, takerFee: nil, spotVolumeUSD: 10, urls: nil),
                2: ExchangeInfoDTO(id: 2, name: "High Volume", slug: "high", logo: nil, description: nil, dateLaunched: nil, makerFee: nil, takerFee: nil, spotVolumeUSD: 20, urls: nil)
            ],
            assets: []
        )

        let repository = LiveExchangesRepository(service: service)
        let exchanges = try await repository.fetchExchanges()

        #expect(exchanges.map(\.id) == [2, 1])
    }

    @Test
    func fetchExchangesRemovesDuplicateExchangeIDs() async throws {
        let service = ExchangeServiceFake(
            listings: [
                ExchangeListingDTO(
                    id: 6929,
                    name: "Duplicate Low",
                    slug: "dup-low",
                    numMarketPairs: nil,
                    dateLaunched: nil,
                    quote: ["USD": ExchangeVolumeQuoteDTO(volume24h: 10, volume24hAdjusted: nil, effectiveLiquidity24h: nil, lastUpdated: nil)],
                    lastUpdated: nil
                ),
                ExchangeListingDTO(
                    id: 6929,
                    name: "Duplicate High",
                    slug: "dup-high",
                    numMarketPairs: nil,
                    dateLaunched: nil,
                    quote: ["USD": ExchangeVolumeQuoteDTO(volume24h: 20, volume24hAdjusted: nil, effectiveLiquidity24h: nil, lastUpdated: nil)],
                    lastUpdated: nil
                ),
                ExchangeListingDTO(
                    id: 7,
                    name: "Unique",
                    slug: "unique",
                    numMarketPairs: nil,
                    dateLaunched: nil,
                    quote: ["USD": ExchangeVolumeQuoteDTO(volume24h: 15, volume24hAdjusted: nil, effectiveLiquidity24h: nil, lastUpdated: nil)],
                    lastUpdated: nil
                )
            ],
            info: [
                6929: ExchangeInfoDTO(id: 6929, name: "Duplicate", slug: "duplicate", logo: nil, description: nil, dateLaunched: nil, makerFee: nil, takerFee: nil, spotVolumeUSD: nil, urls: nil),
                7: ExchangeInfoDTO(id: 7, name: "Unique", slug: "unique", logo: nil, description: nil, dateLaunched: nil, makerFee: nil, takerFee: nil, spotVolumeUSD: nil, urls: nil)
            ],
            assets: []
        )

        let repository = LiveExchangesRepository(service: service)
        let exchanges = try await repository.fetchExchanges()

        #expect(exchanges.map(\.id) == [6929, 7])
        #expect(exchanges.count == 2)
    }

    @Test
    func fetchExchangeDetailMapsAssetsAndMetadata() async throws {
        let service = ExchangeServiceFake(
            listings: [],
            info: [
                270: ExchangeInfoDTO(
                    id: 270,
                    name: "Binance",
                    slug: "binance",
                    logo: URL(string: "https://example.com/logo.png"),
                    description: "Descricao",
                    dateLaunched: Date(timeIntervalSince1970: 1),
                    makerFee: 0.02,
                    takerFee: 0.04,
                    spotVolumeUSD: 999,
                    urls: ExchangeURLsDTO(website: [URL(string: "https://binance.com")!])
                )
            ],
            assets: [
                ExchangeAssetDTO(
                    walletAddress: "0x1",
                    balance: 1,
                    platform: nil,
                    currency: ExchangeAssetCurrencyDTO(cryptoID: 2, name: "Litecoin", symbol: "LTC", priceUSD: 90)
                ),
                ExchangeAssetDTO(
                    walletAddress: "0x2",
                    balance: 1,
                    platform: nil,
                    currency: ExchangeAssetCurrencyDTO(cryptoID: 1, name: "Bitcoin", symbol: "BTC", priceUSD: 60000)
                )
            ]
        )

        let repository = LiveExchangesRepository(service: service)
        let detail = try await repository.fetchExchangeDetail(exchangeID: 270)

        #expect(detail.name == "Binance")
        #expect(detail.websiteURL?.absoluteString == "https://binance.com")
        #expect(detail.assets.map(\.currencyName) == ["Bitcoin", "Litecoin"])
    }
}

private struct ExchangeServiceFake: ExchangeService {
    let listings: [ExchangeListingDTO]
    let info: [Int: ExchangeInfoDTO]
    let assets: [ExchangeAssetDTO]

    func fetchListings(limit: Int) async throws -> [ExchangeListingDTO] {
        listings
    }

    func fetchInfo(ids: [Int]) async throws -> [Int: ExchangeInfoDTO] {
        info
    }

    func fetchAssets(exchangeID: Int) async throws -> [ExchangeAssetDTO] {
        assets
    }
}
