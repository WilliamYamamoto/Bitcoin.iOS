import Foundation
import Testing
@testable import Desafio

struct AppConfigTests {
    @Test
    func loadPrefersEnvironmentValueWhenPresent() {
        let config = AppConfig.load(bundle: .main, environment: ["CMC_API_KEY": "env-key"])
        #expect(config.apiKey == "env-key")
    }

    @Test
    func loadReturnsNilForEmptyValue() {
        let config = AppConfig.load(bundle: .main, environment: ["CMC_API_KEY": "   "])
        #expect(config.apiKey == nil)
    }
}
