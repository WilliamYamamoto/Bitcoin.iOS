import SwiftUI

struct ExchangeDetailHeaderView: View {
    let detail: ExchangeDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                RemoteImageView(url: detail.logoURL, size: 72)

                VStack(alignment: .leading, spacing: 6) {
                    Text(detail.name)
                        .font(.title2.bold())
                        .accessibilityIdentifier("exchange_detail_title")

                    Text("ID \(detail.id)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let description = detail.description, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .accessibilityIdentifier("exchange_detail_description")
            }

            detailRow(title: "Data de lancamento", value: detail.dateLaunched.map { Formatters.date.string(from: $0) })
            detailRow(title: "Maker fee", value: detail.makerFee?.formattedFeePercent)
            detailRow(title: "Taker fee", value: detail.takerFee?.formattedFeePercent)

            if let websiteURL = detail.websiteURL {
                Link(destination: websiteURL) {
                    Label("Abrir website", systemImage: "safari")
                }
                .accessibilityIdentifier("exchange_detail_website_link")
            }
        }
    }

    @ViewBuilder
    private func detailRow(title: String, value: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value ?? "Indisponivel")
                .font(.body)
                .accessibilityIdentifier("exchange_detail_\(title.replacingOccurrences(of: " ", with: "_").lowercased())")
        }
    }
}
