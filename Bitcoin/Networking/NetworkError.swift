import Foundation

enum NetworkError: Error, Equatable, LocalizedError, Sendable {
    case invalidURL
    case missingAPIKey
    case offline
    case timeout
    case rateLimited
    case httpStatus(code: Int, message: String?)
    case decoding
    case unexpected(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Nao foi possivel montar a requisicao."
        case .missingAPIKey:
            return "Configure a chave CMC_API_KEY via Config.xcconfig ou Scheme antes de usar o app."
        case .offline:
            return "Parece que voce esta offline. Verifique sua conexao e tente novamente."
        case .timeout:
            return "A requisicao demorou mais do que o esperado. Tente novamente."
        case .rateLimited:
            return "Limite de requisicoes atingido na API da CoinMarketCap. Tente novamente em instantes."
        case .httpStatus(let code, let message):
            return message ?? "A API retornou erro \(code)."
        case .decoding:
            return "Nao foi possivel interpretar a resposta da API."
        case .unexpected(let message):
            return message
        }
    }
}
