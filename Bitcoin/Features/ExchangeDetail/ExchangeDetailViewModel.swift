import Foundation
import Combine

@MainActor
final class ExchangeDetailViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded(ExchangeDetail)
        case empty
        case error(String)
    }

    @Published private(set) var state: State = .idle

    let exchangeID: Int
    private let repository: ExchangesRepository

    init(exchangeID: Int, repository: ExchangesRepository) {
        self.exchangeID = exchangeID
        self.repository = repository
    }

    func load() async {
        // Prevent flicker if already loading
        if case .loading = state { return }
        state = .loading

        do {
            let detail = try await repository.fetchExchangeDetail(exchangeID: exchangeID)
            // Consider empty state if there is no meaningful data (e.g., no assets and no description)
            if (detail.assets.isEmpty) && (detail.description?.isEmpty ?? true) {
                state = .empty
            } else {
                state = .loaded(detail)
            }
        } catch let decodingError as DecodingError {
            // Provide a clearer, localized message for decoding problems
            let message: String
            switch decodingError {
            case .keyNotFound(let key, let context):
                message = "Nao foi possivel interpretar a resposta da API. Chave ausente: \(key.stringValue) em \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .typeMismatch(let type, let context):
                message = "Nao foi possivel interpretar a resposta da API. Tipo incorreto: \(type) em \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .valueNotFound(let type, let context):
                message = "Nao foi possivel interpretar a resposta da API. Valor ausente para: \(type) em \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .dataCorrupted(let context):
                message = "Nao foi possivel interpretar a resposta da API. Dados corrompidos em: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            @unknown default:
                message = "Nao foi possivel interpretar a resposta da API."
            }
            state = .error(message)
        } catch {
            // Map other errors to their descriptions
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            state = .error(message)
        }
    }
}
