import Foundation

struct ExchangeAssetDTO: Decodable {
    let walletAddress: String?
    let balance: Decimal?
    let platform: ExchangeAssetPlatformDTO?
    let currency: ExchangeAssetCurrencyDTO

    var assetID: String {
        let idPart = currency.cryptoID.map(String.init) ?? "unknown"
        return "\(idPart)-\(walletAddress ?? "wallet")"
    }

    enum CodingKeys: String, CodingKey {
        case walletAddress = "wallet_address"
        case balance
        case platform
        case currency
    }
}

struct ExchangeAssetPlatformDTO: Decodable {
    let cryptoID: Int?
    let symbol: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case cryptoID = "crypto_id"
        case symbol
        case name
    }
}

struct ExchangeAssetCurrencyDTO: Decodable {
    let cryptoID: Int?
    let name: String
    let symbol: String?
    let priceUSD: Decimal?

    enum CodingKeys: String, CodingKey {
        case cryptoID = "crypto_id"
        case name
        case symbol
        case priceUSD = "price_usd"
    }
}
