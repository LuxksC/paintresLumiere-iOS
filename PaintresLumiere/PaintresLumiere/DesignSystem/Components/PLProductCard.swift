import SwiftUI

// MARK: - PLProductCard

//
// Catalog tile used in both the "Most Popular" carousel and the main grid.
// Width is determined by the parent — pass a `frame(width:)` for the
// carousel, let it fill a `GridItem(.flexible())` for the grid.
//
// Discount affordances (badge + strikethrough original price) are only shown
// when `product.pricing.hasDiscount` is true.

struct PLProductCard: View {
    let product: Product
    let action: () -> Void

    var body: some View {
        Button(action: action) { content }
            .buttonStyle(PLProductCardButtonStyle())
            .accessibilityLabel(Text(product.name))
            .accessibilityValue(Text(accessibilityPrice))
    }

    // MARK: - Sub-views

    private var content: some View {
        VStack(alignment: .leading, spacing: PLSpacing.sm) {
            imageBlock
            textBlock
        }
        .padding(PLSpacing.sm)
        .background(PLColor.backgroundElevated)
        .overlay {
            RoundedRectangle(cornerRadius: PLRadius.card)
                .stroke(PLColor.borderSubtle, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: PLRadius.card))
    }

    private var imageBlock: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topTrailing) {
                PLRemoteImage(url: product.primaryImageURL)
                    .frame(width: proxy.size.width, height: proxy.size.width)
                    .clipShape(.rect(cornerRadius: PLRadius.card - 2))

                imageBadges
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.horizontal, PLSpacing.sm)
    }

    private var imageBadges: some View {
        Group {
            if product.pricing.hasDiscount {
                Text(product.pricing.discountPercentLabel)
                    .font(PLFont.label())
                    .foregroundStyle(PLColor.backgroundPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(PLColor.goldBright)
                    .clipShape(.rect(cornerRadius: PLRadius.badge))
                    .padding(PLSpacing.sm)
            }

            if !product.status.isPurchasable {
                outOfStockOverlay
            }
        }
    }

    private var outOfStockOverlay: some View {
        ZStack {
            Color.black.opacity(0.55)
            Text(product.status.displayName.uppercased())
                .font(PLFont.label())
                .tracking(1)
                .foregroundStyle(PLColor.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(PLColor.backgroundPrimary.opacity(0.7))
                .clipShape(.rect(cornerRadius: PLRadius.badge))
        }
        .clipShape(.rect(cornerRadius: PLRadius.card - 2))
    }

    private var textBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.name)
                .font(PLFont.button())
                .foregroundStyle(PLColor.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            PLProductPriceRow(pricing: product.pricing)
        }
    }

    // MARK: - Helpers

    private var accessibilityPrice: String {
        if product.pricing.hasDiscount {
            let from = product.pricing.sellingPrice.brlFormatted
            let to = product.pricing.finalPrice.brlFormatted
            return "\(to), down from \(from)"
        }
        return product.pricing.finalPrice.brlFormatted
    }
}

// MARK: - PLProductPriceRow

struct PLProductPriceRow: View {
    let pricing: ProductPricing

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(pricing.finalPrice.brlFormatted)
                .font(PLFont.button())
                .foregroundStyle(PLColor.goldBright)

            if pricing.hasDiscount {
                Text(pricing.sellingPrice.brlFormatted)
                    .font(PLFont.caption())
                    .foregroundStyle(PLColor.textMuted)
                    .strikethrough()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Pressed-state button style

private struct PLProductCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}

// MARK: - Decimal → BRL helper

extension Decimal {
    var brlFormatted: String {
        formatted(.currency(code: "BRL").locale(Locale(identifier: "pt_BR")))
    }
}

// MARK: - Preview

#Preview {
    let service = PreviewProductService()
    let products = (try? service.previewProducts()) ?? []

    return ScrollView {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: PLSpacing.md),
                      GridItem(.flexible(), spacing: PLSpacing.md)],
            spacing: PLSpacing.md
        ) {
            ForEach(products) { product in
                PLProductCard(product: product) {}
            }
        }
        .padding()
    }
    .background(PLColor.backgroundPrimary)
}

#if DEBUG
    private extension PreviewProductService {
        func previewProducts() throws -> [Product] {
            try JsonHelper.decodeFixture(
                "products_response",
                as: ProductsResponse<Product>.self
            ).products
        }
    }
#endif
