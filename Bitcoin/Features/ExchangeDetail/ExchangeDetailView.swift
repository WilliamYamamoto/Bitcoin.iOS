import SwiftUI

struct ExchangeDetailView: View {
    @StateObject private var viewModel: ExchangeDetailViewModel

    init(viewModel: ExchangeDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("Detalhe")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Ensure we only trigger load once when appearing
                if case .idle = viewModel.state {
                    Task { await viewModel.load() }
                }
            }
            .refreshable {
                await viewModel.load()
            }
            .accessibilityIdentifier("exchange_detail_root")
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ZStack {
                Color.clear
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Carregando detalhe")
                        .font(.headline)
                    Text("Buscando informacoes da exchange e dos assets.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityIdentifier("exchange_detail_loading")
            }
        case .empty:
            EmptyView()
        case .error(let message):
            ZStack {
                Color.clear
                    .ignoresSafeArea()
                ScreenStateView(
                    title: "Nao foi possivel carregar o detalhe",
                    subtitle: message,
                    systemImage: "exclamationmark.triangle",
                    actionTitle: "Tentar novamente",
                    action: { Task { await viewModel.load() } },
                    identifier: "exchange_detail_error"
                )
            }
        case .loaded(let detail):
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ExchangeDetailHeaderView(detail: detail)
                    ExchangeAssetsSectionView(assets: detail.assets)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .scrollIndicators(.visible)
        }
    }
}

#Preview {
    NavigationStack {
        ExchangeDetailView(viewModel: AppContainer.preview.makeExchangeDetailViewModel(exchangeID: 270))
    }
}
