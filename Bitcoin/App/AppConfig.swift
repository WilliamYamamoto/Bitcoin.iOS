import Foundation

struct AppConfig: Sendable {
    let apiKey: String?
    let baseURL: URL
    let requestTimeout: TimeInterval

    static func load(bundle: Bundle = .main, environment: [String: String] = ProcessInfo.processInfo.environment) -> AppConfig {
        let bundleKey = bundle.object(forInfoDictionaryKey: "CMC_API_KEY") as? String
        let envKey = environment["CMC_API_KEY"]
        let normalizedKey = [envKey, bundleKey]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first(where: { !$0.isEmpty && !$0.contains("$(") })

        return AppConfig(
            apiKey: normalizedKey,
            baseURL: URL(string: "https://sandbox-api.coinmarketcap.com")!,
//            baseURL: URL(string: "https://pro-api.coinmarketcap.com")!,
            requestTimeout: 30
        )
    }
}

enum AppLaunchScenario: String, Sendable {
    case live
    case uiSuccess = "ui_success"
    case uiEmpty = "ui_empty"
    case uiError = "ui_error"
    case uiRateLimit = "ui_rate_limit"

    static func current(arguments: [String] = ProcessInfo.processInfo.arguments) -> AppLaunchScenario {
        guard let index = arguments.firstIndex(of: "-uiScenario"), arguments.indices.contains(index + 1) else {
            return .live
        }

        return AppLaunchScenario(rawValue: arguments[index + 1]) ?? .live
    }
}
