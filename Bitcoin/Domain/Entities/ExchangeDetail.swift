import Foundation

struct ExchangeDetail: Equatable, Sendable {
    let id: Int
    let name: String
    let logoURL: URL?
    let description: String?
    let websiteURL: URL?
    let makerFee: Decimal?
    let takerFee: Decimal?
    let dateLaunched: Date?
    let assets: [ExchangeAsset]
}
