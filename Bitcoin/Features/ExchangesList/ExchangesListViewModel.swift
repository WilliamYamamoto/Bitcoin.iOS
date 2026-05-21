import Foundation
import Combine

@MainActor
final class ExchangesListViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded([ExchangeSummary])
        case empty
        case error(String)
    }

    @Published private(set) var state: State = .idle

    private let repository: ExchangesRepository

    init(repository: ExchangesRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading

        do {
            let exchanges = try await repository.fetchExchanges()
            state = exchanges.isEmpty ? .empty : .loaded(exchanges)
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            state = .error(message)
        }
    }
}
