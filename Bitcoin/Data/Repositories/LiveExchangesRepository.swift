import Foundation

struct LiveExchangesRepository: ExchangesRepository {
    let service: ExchangeService

    func fetchExchanges() async throws -> [ExchangeSummary] {
        let listings = try await service.fetchListings(limit: 30)
        let infoByID = try await service.fetchInfo(ids: listings.map(\.id))

        let sortedExchanges = listings
            .map { listing in
                let info = infoByID[listing.id]
                return ExchangeSummary(
                    id: listing.id,
                    name: listing.name,
                    logoURL: info?.logo,
                    spotVolumeUSD: info?.spotVolumeUSD ?? listing.spotVolumeUSD,
                    dateLaunched: info?.dateLaunched ?? listing.dateLaunched
                )
            }
            .sorted {
                switch ($0.spotVolumeUSD, $1.spotVolumeUSD) {
                case let (lhs?, rhs?):
                    return lhs > rhs
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
            }

        var seenIDs = Set<Int>()
        return sortedExchanges.filter { seenIDs.insert($0.id).inserted }
    }

    func fetchExchangeDetail(exchangeID: Int) async throws -> ExchangeDetail {
        async let info = service.fetchInfo(ids: [exchangeID])
        async let assets = service.fetchAssets(exchangeID: exchangeID)

        let infoMap = try await info
        let assetDTOs = try await assets
        guard let exchangeInfo = infoMap[exchangeID] else {
            throw NetworkError.unexpected("Nao foi possivel encontrar os detalhes da exchange.")
        }

        return ExchangeDetail(
            id: exchangeInfo.id,
            name: exchangeInfo.name,
            logoURL: exchangeInfo.logo,
            description: exchangeInfo.description,
            websiteURL: exchangeInfo.urls?.website?.first,
            makerFee: exchangeInfo.makerFee,
            takerFee: exchangeInfo.takerFee,
            dateLaunched: exchangeInfo.dateLaunched,
            assets: assetDTOs.map {
                ExchangeAsset(
                    id: $0.assetID,
                    currencyName: $0.currency.name,
                    priceUSD: $0.currency.priceUSD
                )
            }
            .sorted { $0.currencyName.localizedCaseInsensitiveCompare($1.currencyName) == .orderedAscending }
        )
    }
}
