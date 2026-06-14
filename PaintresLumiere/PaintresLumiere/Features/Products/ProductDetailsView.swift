import SwiftUI

// MARK: - ProductDetailsView
//
// Five-section detail screen with a sticky `.thinMaterial` footer:
//  1. Images (carousel + dot indicator)
//  2. Title & price
//  3. Variant selectors (color / size) — only shown if >1 option exists
//  4. About (description + stock prominent; technical details below)
//  5. Footer (quantity stepper + buy + cart) — fixed at the bottom

struct ProductDetailsView: View {

    @Bindable var viewModel: ProductDetailsViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            PLColor.backgroundPrimary.ignoresSafeArea()
            content
            if viewModel.state == .loaded, viewModel.selectedVariant != nil {
                FooterBar(viewModel: viewModel)
            }
        }
        .overlay(alignment: .topLeading) {
            BackChevronButton { viewModel.dismiss() }
                .padding(.leading, PLSpacing.md)
                .padding(.top, PLSpacing.sm)
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if viewModel.state == .idle { await viewModel.load() }
        }
    }

    // MARK: - States

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .tint(PLColor.goldMid)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            ErrorState(message: message) {
                Task { await viewModel.load() }
            }
        case .loaded:
            if let variant = viewModel.selectedVariant {
                LoadedContent(viewModel: viewModel, variant: variant)
            } else {
                ErrorState(message: "This product is unavailable right now.") {
                    viewModel.dismiss()
                }
            }
        }
    }
}

// MARK: - Loaded content

private struct LoadedContent: View {

    @Bindable var viewModel: ProductDetailsViewModel
    let variant: ProductVariant

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ImageCarouselSection(images: variant.images)

                VStack(alignment: .leading, spacing: PLSpacing.xl) {
                    TitleAndPriceSection(variant: variant)

                    if viewModel.hasMultipleColors || viewModel.hasMultipleSizes {
                        VariantSelectorsSection(viewModel: viewModel)
                    }

                    AboutSection(variant: variant)
                }
                .padding(.horizontal, PLSpacing.xl)
                .padding(.top, PLSpacing.xl)
                .padding(.bottom, 120)  // reserve room for the sticky footer
            }
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - 1. Image carousel

private struct ImageCarouselSection: View {

    let images: [String]
    @State private var currentIndex: Int = 0

    var body: some View {
        VStack(spacing: PLSpacing.md) {
            ZStack {
                if images.isEmpty {
                    PLRemoteImage(url: nil)
                        .aspectRatio(1, contentMode: .fill)
                } else {
                    TabView(selection: $currentIndex) {
                        ForEach(images.indices, id: \.self) { index in
                            PLRemoteImage(urlString: images[index])
                                .aspectRatio(1, contentMode: .fill)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .aspectRatio(1, contentMode: .fit)
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()

            PLPageIndicator(count: images.count, activeIndex: currentIndex)
        }
    }
}

// MARK: - 2. Title & price

private struct TitleAndPriceSection: View {

    let variant: ProductVariant

    var body: some View {
        HStack(alignment: .top, spacing: PLSpacing.md) {
            VStack(alignment: .leading, spacing: PLSpacing.xs) {
                Text(variant.name)
                    .font(PLFont.h1())
                    .foregroundStyle(PLColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                priceBlock
            }
            Spacer(minLength: 0)

            if variant.pricing.hasDiscount {
                Text(variant.pricing.discountPercentLabel)
                    .font(PLFont.button())
                    .foregroundStyle(PLColor.backgroundPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(PLColor.goldBright)
                    .clipShape(.rect(cornerRadius: PLRadius.badge))
            }
        }
    }

    @ViewBuilder
    private var priceBlock: some View {
        HStack(alignment: .firstTextBaseline, spacing: PLSpacing.sm) {
            Text(variant.pricing.finalPrice.brlFormatted)
                .font(PLFont.h2())
                .foregroundStyle(PLColor.goldBright)

            if variant.pricing.hasDiscount {
                Text(variant.pricing.sellingPrice.brlFormatted)
                    .font(PLFont.body())
                    .foregroundStyle(PLColor.textMuted)
                    .strikethrough()
            }
        }
    }
}

// MARK: - 3. Variant selectors

private struct VariantSelectorsSection: View {

    @Bindable var viewModel: ProductDetailsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: PLSpacing.lg) {
            if viewModel.hasMultipleColors {
                VStack(alignment: .leading, spacing: PLSpacing.sm) {
                    SectionLabel(text: "COLOR", value: viewModel.selectedColor?.displayName)
                    PLColorSelector(
                        colors: viewModel.availableColors,
                        enabled: viewModel.enabledColors,
                        selection: viewModel.colorBinding
                    )
                }
            }

            if viewModel.hasMultipleSizes {
                VStack(alignment: .leading, spacing: PLSpacing.sm) {
                    SectionLabel(text: "SIZE", value: viewModel.selectedSize)
                    PLSizeSelector(
                        sizes: viewModel.availableSizes,
                        enabled: viewModel.enabledSizes,
                        selection: viewModel.sizeBinding
                    )
                }
            }
        }
    }
}

private struct SectionLabel: View {
    let text: String
    let value: String?
    var body: some View {
        HStack(spacing: PLSpacing.sm) {
            Text(text)
                .font(PLFont.label())
                .tracking(1.5)
                .foregroundStyle(PLColor.textMuted)
            if let value {
                Text("·")
                    .foregroundStyle(PLColor.textDisabled)
                Text(value)
                    .font(PLFont.caption())
                    .foregroundStyle(PLColor.textSecondary)
            }
        }
    }
}

// MARK: - 4. About

private struct AboutSection: View {

    let variant: ProductVariant

    var body: some View {
        VStack(alignment: .leading, spacing: PLSpacing.lg) {
            DescriptionAndStockCard(variant: variant)
            DetailsList(variant: variant)
        }
    }
}

private struct DescriptionAndStockCard: View {

    let variant: ProductVariant

    var body: some View {
        VStack(alignment: .leading, spacing: PLSpacing.md) {
            SectionLabel(text: "ABOUT", value: nil)

            if let description = variant.description, !description.isEmpty {
                Text(description)
                    .font(PLFont.body())
                    .foregroundStyle(PLColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            stockBadge
        }
        .padding(PLSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PLColor.backgroundElevated)
        .overlay {
            RoundedRectangle(cornerRadius: PLRadius.card)
                .stroke(PLColor.borderSubtle, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: PLRadius.card))
    }

    private var stockBadge: some View {
        HStack(spacing: PLSpacing.sm) {
            Circle()
                .fill(stockColor)
                .frame(width: 8, height: 8)
            Text(stockText)
                .font(PLFont.caption())
                .foregroundStyle(PLColor.textPrimary)
        }
    }

    private var stockColor: Color {
        switch variant.status {
        case .active:     PLColor.success
        case .outOfStock: PLColor.error
        case .inactive:   PLColor.textDisabled
        }
    }

    private var stockText: String {
        switch variant.status {
        case .active:     "In stock · \(variant.stockQuantity) available"
        case .outOfStock: "Out of stock"
        case .inactive:   "Unavailable"
        }
    }
}

private struct DetailsList: View {

    let variant: ProductVariant

    var body: some View {
        VStack(alignment: .leading, spacing: PLSpacing.sm) {
            SectionLabel(text: "DETAILS", value: nil)

            VStack(spacing: 0) {
                DetailRow(label: "Category", value: variant.category.displayName)
                Divider().overlay(PLColor.borderSubtle)
                DetailRow(label: "Dimensions", value: variant.sizeLabel)
                if let barcode = variant.barcode {
                    Divider().overlay(PLColor.borderSubtle)
                    DetailRow(label: "Barcode", value: barcode)
                }
                Divider().overlay(PLColor.borderSubtle)
                DetailRow(label: "SKU", value: variant.slug)
            }
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(PLFont.caption())
                .foregroundStyle(PLColor.textMuted)
            Spacer()
            Text(value)
                .font(PLFont.caption())
                .foregroundStyle(PLColor.textSecondary)
        }
        .padding(.vertical, PLSpacing.sm)
    }
}

// MARK: - 5. Sticky footer

private struct FooterBar: View {

    @Bindable var viewModel: ProductDetailsViewModel

    var body: some View {
        HStack(spacing: PLSpacing.md) {
            PLQuantityStepper(
                value: $viewModel.quantity,
                range: 1...max(viewModel.maxQuantity, 1)
            )
            .disabled(!viewModel.canPurchase)
            .opacity(viewModel.canPurchase ? 1 : 0.4)

            PLButton(viewModel.canPurchase ? "Buy" : "Unavailable") {
                viewModel.buyNow()
            }
            .disabled(!viewModel.canPurchase)

            Button("Add to cart", systemImage: "cart.badge.plus") {
                viewModel.addToCart()
            }
            .labelStyle(.iconOnly)
            .font(.system(.title3, weight: .semibold))
            .foregroundStyle(viewModel.canPurchase ? PLColor.goldBright : PLColor.textDisabled)
            .frame(width: 52, height: 52)
            .background(PLColor.backgroundElevated)
            .overlay {
                RoundedRectangle(cornerRadius: PLRadius.button)
                    .stroke(PLColor.borderSubtle, lineWidth: 1)
            }
            .clipShape(.rect(cornerRadius: PLRadius.button))
            .disabled(!viewModel.canPurchase)
        }
        .padding(.horizontal, PLSpacing.xl)
        .padding(.vertical, PLSpacing.md)
        .background {
            Rectangle()
                .fill(.thinMaterial)
                .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(PLColor.borderSubtle)
                .frame(height: 1)
        }
    }
}

// MARK: - Back chevron

private struct BackChevronButton: View {
    let action: () -> Void
    var body: some View {
        Button("Back", systemImage: "chevron.left", action: action)
            .labelStyle(.iconOnly)
            .font(.system(.body, weight: .semibold))
            .foregroundStyle(PLColor.textPrimary)
            .frame(width: 40, height: 40)
            .background(.thinMaterial)
            .clipShape(.circle)
    }
}

// MARK: - Error state

private struct ErrorState: View {
    let message: String
    let onRetry: () -> Void
    var body: some View {
        VStack(spacing: PLSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundStyle(PLColor.warning)
            Text("Couldn't load this product")
                .font(PLFont.h2())
                .foregroundStyle(PLColor.textPrimary)
            Text(message)
                .font(PLFont.body())
                .foregroundStyle(PLColor.textMuted)
                .multilineTextAlignment(.center)
            PLButton("Try again", action: onRetry)
                .frame(maxWidth: 220)
        }
        .padding(PLSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    let viewModel = ProductDetailsViewModel(
        sku: "NAME-LUNA",
        productService: PreviewProductService(),
        messages: PreviewMessagesService()
    )
    return ProductDetailsView(viewModel: viewModel)
}

private final class PreviewMessagesService: MessagesServiceProtocol {
    func show(_ message: ToastMessage) {}
    func dismissCurrent() {}
    func attach(to scene: UIWindowScene) {}
    func showNetworkError() {}
    func showGenericError() {}
    func showAddedToCart(productName: String) {}
    func showComingSoon() {}
}
#endif
