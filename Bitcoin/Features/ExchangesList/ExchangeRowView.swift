import SwiftUI

struct ExchangeRowView: View {
    let exchange: ExchangeSummary

    var body: some View {
        HStack(spacing: 12) {
            RemoteImageView(url: exchange.logoURL, size: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(exchange.name)
                    .font(.headline)
                    .lineLimit(1)
                    .accessibilityIdentifier("exchange_cell_name_\(exchange.id)")

                Text(exchange.spotVolumeUSD?.formattedUSD ?? "Volume indisponivel")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("exchange_cell_volume_\(exchange.id)")

                Text(exchange.dateLaunched.map { Formatters.date.string(from: $0) } ?? "Data indisponivel")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(exchange.accessibilityDescription)
    }
}
