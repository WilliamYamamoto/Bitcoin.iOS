import Foundation

struct PreviewExchangesRepository: ExchangesRepository {
    func fetchExchanges() async throws -> [ExchangeSummary] {
        [
            ExchangeSummary(
                id: 270,
                name: "Mercado Bitcoin",
                logoURL: nil,
                spotVolumeUSD: 128_450_900,
                dateLaunched: Calendar.current.date(from: DateComponents(year: 2013, month: 6, day: 1))
            ),
            ExchangeSummary(
                id: 89,
                name: "Binance",
                logoURL: nil,
                spotVolumeUSD: 992_110_100,
                dateLaunched: Calendar.current.date(from: DateComponents(year: 2017, month: 7, day: 1))
            )
        ]
    }

    func fetchExchangeDetail(exchangeID: Int) async throws -> ExchangeDetail {
        ExchangeDetail(
            id: exchangeID,
            name: exchangeID == 270 ? "Mercado Bitcoin" : "Binance",
            logoURL: nil,
            description: "Preview local para acelerar o desenvolvimento da UI.",
            websiteURL: URL(string: "https://www.mercadobitcoin.com.br"),
            makerFee: 0.003,
            takerFee: 0.007,
            dateLaunched: Calendar.current.date(from: DateComponents(year: 2013, month: 6, day: 1)),
            assets: [
                ExchangeAsset(id: "1", currencyName: "Bitcoin", priceUSD: 67_000),
                ExchangeAsset(id: "1027", currencyName: "Ethereum", priceUSD: 3_200),
                ExchangeAsset(id: "825", currencyName: "Tether USDt", priceUSD: 1)
            ]
        )
    }
}
