import SwiftUI
import Kingfisher

// MARK: - PLRemoteImage
//
// Project-wide wrapper around `KFImage`. Centralizes the placeholder, fade,
// and cancellation behavior so every remote image in the app looks the same.
// Pass `nil` (or omit the URL) to render the placeholder directly — useful
// for products that have no images yet.

struct PLRemoteImage: View {

    let url: URL?
    var contentMode: SwiftUI.ContentMode = .fill

    init(url: URL?, contentMode: SwiftUI.ContentMode = .fill) {
        self.url = url
        self.contentMode = contentMode
    }

    init(urlString: String?, contentMode: SwiftUI.ContentMode = .fill) {
        self.url = urlString.flatMap(URL.init(string:))
        self.contentMode = contentMode
    }

    var body: some View {
        if let url {
            KFImage(url)
                .resizable()
                .placeholder { PLImagePlaceholder() }
                .fade(duration: 0.2)
                .cancelOnDisappear(true)
                .aspectRatio(contentMode: contentMode)
        } else {
            PLImagePlaceholder()
        }
    }
}

// MARK: - PLImagePlaceholder

struct PLImagePlaceholder: View {
    var body: some View {
        ZStack {
            PLColor.backgroundElevated
            Image(systemName: "photo")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(PLColor.goldAntique)
        }
    }
}

// MARK: - Preview

#Preview("Remote · Placeholder") {
    HStack(spacing: PLSpacing.md) {
        PLRemoteImage(urlString: "https://images.unsplash.com/photo-1582582494705-f8ce0b0c24f0?w=400")
            .frame(width: 140, height: 140)
            .clipShape(.rect(cornerRadius: PLRadius.card))

        PLRemoteImage(urlString: nil)
            .frame(width: 140, height: 140)
            .clipShape(.rect(cornerRadius: PLRadius.card))
    }
    .padding()
    .background(PLColor.backgroundPrimary)
}
