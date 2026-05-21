import SwiftUI

struct RemoteImageView: View {
    let url: URL?
    let size: CGFloat

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                placeholder
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                fallback
            @unknown default:
                fallback
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
    }

    private var fallback: some View {
        Image(systemName: "building.2.crop.circle")
            .resizable()
            .scaledToFit()
            .padding(10)
            .foregroundStyle(.secondary)
    }
}
