import SwiftUI

struct ExchangesListView: View {
    @StateObject private var viewModel: ExchangesListViewModel
    private let makeDetailViewModel: (Int) -> ExchangeDetailViewModel

    init(
        viewModel: ExchangesListViewModel,
        makeDetailViewModel: @escaping (Int) -> ExchangeDetailViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeDetailViewModel = makeDetailViewModel
    }

    var body: some View {
        content
            .navigationTitle("Exchanges")
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
            .accessibilityIdentifier("exchanges_list_root")
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack(spacing: 16) {
                ProgressView()
                Text("Carregando exchanges")
                    .font(.headline)
                Text("Buscando dados da CoinMarketCap.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(0 ..< 4, id: \.self) { _ in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 48, height: 48)
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                                .frame(width: 180, height: 14)
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                                .frame(width: 120, height: 12)
                        }
                    }
                    .redacted(reason: .placeholder)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier("exchanges_list_loading")
        case .empty:
            ScreenStateView(
                title: "Nenhuma exchange encontrada",
                subtitle: "Puxe para atualizar ou tente novamente.",
                systemImage: "tray",
                actionTitle: "Tentar novamente",
                action: { Task { await viewModel.load() } },
                identifier: "exchanges_list_empty"
            )
        case .error(let message):
            ScreenStateView(
                title: "Nao foi possivel carregar",
                subtitle: message,
                systemImage: "wifi.exclamationmark",
                actionTitle: "Tentar novamente",
                action: { Task { await viewModel.load() } },
                identifier: "exchanges_list_error"
            )
        case .loaded(let exchanges):
            List(exchanges) { exchange in
                NavigationLink {
                    ExchangeDetailView(viewModel: makeDetailViewModel(exchange.id))
                } label: {
                    ExchangeRowView(exchange: exchange)
                }
                .accessibilityIdentifier("exchange_cell_\(exchange.id)")
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        ExchangesListView(
            viewModel: AppContainer.preview.makeExchangesListViewModel(),
            makeDetailViewModel: AppContainer.preview.makeExchangeDetailViewModel(exchangeID:)
        )
    }
}
