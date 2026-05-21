import Foundation

struct ExchangeAsset: Identifiable, Equatable, Sendable {
    let id: String
    let currencyName: String
    let priceUSD: Decimal?
}
