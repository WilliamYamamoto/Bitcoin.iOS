import Foundation

extension Decimal {
    var formattedUSD: String {
        let number = NSDecimalNumber(decimal: self)
        return Formatters.usd.string(from: number) ?? "USD \(number)"
    }

    var formattedFeePercent: String {
        let number = NSDecimalNumber(decimal: self)
        let value = Formatters.fee.string(from: number) ?? "\(number)"
        return "\(value)%"
    }
}

extension ExchangeSummary {
    var accessibilityDescription: String {
        let volumeText = spotVolumeUSD?.formattedUSD ?? "volume indisponivel"
        let dateText = dateLaunched.map { Formatters.date.string(from: $0) } ?? "data indisponivel"
        return "\(name), volume spot \(volumeText), lancada em \(dateText)"
    }
}
