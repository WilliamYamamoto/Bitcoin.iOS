import Foundation

struct ExchangeSummary: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let logoURL: URL?
    let spotVolumeUSD: Decimal?
    let dateLaunched: Date?
}
