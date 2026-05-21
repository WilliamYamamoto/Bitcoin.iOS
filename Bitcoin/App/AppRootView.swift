import SwiftUI

struct AppRootView: View {
    let container: AppContainer

    var body: some View {
        NavigationStack {
            ExchangesListView(
                viewModel: container.makeExchangesListViewModel(),
                makeDetailViewModel: container.makeExchangeDetailViewModel(exchangeID:)
            )
        }
    }
}

#Preview {
    AppRootView(container: .preview)
}
