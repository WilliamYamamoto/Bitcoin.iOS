import Foundation
import Testing
@testable import Desafio

struct FormattingTests {
    @Test
    func usdFormattingUsesCurrencyPattern() {
        let value = Decimal(string: "12345.67")!
        let formatted = value.formattedUSD

        #expect(formatted.contains("12"))
        #expect(formatted.contains("345"))
    }

    @Test
    func feeFormattingAppendsPercentWithoutScaling() {
        let value = Decimal(string: "0.02")!

        #expect(value.formattedFeePercent == "0.02%")
    }
}
