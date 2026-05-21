import SwiftUI

struct ExchangeAssetsSectionView: View {
    let assets: [ExchangeAsset]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Assets")
                .font(.title3.bold())
                .accessibilityIdentifier("exchange_assets_title")

            Group {
                if assets.isEmpty {
                    ScreenStateView(
                        title: "Nenhum asset encontrado",
                        subtitle: "A exchange nao retornou moedas para esta consulta.",
                        systemImage: "tray",
                        actionTitle: nil,
                        action: nil,
                        identifier: "exchange_detail_empty"
                    )
                    .frame(height: 220)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(assets) { asset in
                            HStack {
                                Text(asset.currencyName)
                                    .font(.body)
                                Spacer()
                                Text(asset.priceUSD?.formattedUSD ?? "N/A")
                                    .font(.subheadline.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .accessibilityIdentifier("exchange_asset_\(asset.id)")
                        }
                    }
                }
            }
            .accessibilityIdentifier("exchange_assets_list")
        }
    }
}
