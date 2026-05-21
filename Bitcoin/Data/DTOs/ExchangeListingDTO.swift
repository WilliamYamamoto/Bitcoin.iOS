import Foundation

struct ExchangeListingDTO: Decodable {
    let id: Int
    let name: String
    let slug: String?
    let numMarketPairs: Int?
    let dateLaunched: Date?
    let quote: [String: ExchangeVolumeQuoteDTO]?
    let lastUpdated: Date?

    var spotVolumeUSD: Decimal? {
        quote?["USD"]?.volume24h
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case slug
        case numMarketPairs = "num_market_pairs"
        case dateLaunched = "date_launched"
        case quote
        case lastUpdated = "last_updated"
    }
}

struct ExchangeVolumeQuoteDTO: Decodable {
    let volume24h: Decimal?
    let volume24hAdjusted: Decimal?
    let effectiveLiquidity24h: Decimal?
    let lastUpdated: Date?

    enum CodingKeys: String, CodingKey {
        case volume24h = "volume_24h"
        case volume24hAdjusted = "volume_24h_adjusted"
        case effectiveLiquidity24h = "effective_liquidity_24h"
        case lastUpdated = "last_updated"
    }
}
