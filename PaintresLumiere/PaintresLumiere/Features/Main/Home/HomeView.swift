import SwiftUI

// MARK: - Home View (e-commerce catalog)

struct HomeView: View {

    @Bindable var viewModel: HomeViewModel

    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: PLSpacing.md),
        GridItem(.flexible(), spacing: PLSpacing.md)
    ]

    var body: some View {
        ZStack {
            PLColor.backgroundPrimary.ignoresSafeArea()
            content
        }
        .task {
            if viewModel.state == .idle { await viewModel.load() }
        }
    }

    // MARK: - States

    @ViewBuilder
    private var content: some View {
        if viewModel.isInitialLoading {
            HomeLoadingView()
        } else if case .failed(let message) = viewModel.state, !viewModel.hasContent {
            HomeErrorView(message: message) {
                Task { await viewModel.load() }
            }
        } else {
            catalogScroll
        }
    }

    // MARK: - Catalog scroll

    private var catalogScroll: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    HomeHeaderView(
                        onNotifications: viewModel.tapNotifications,
                        onCart: viewModel.tapCart
                    )
                    PLDivider().padding(.vertical, PLSpacing.md)
                }
                .padding(.horizontal, PLSpacing.xl)

                if !viewModel.popular.isEmpty {
                    PopularProductsSection(
                        products: viewModel.popular,
                        onSelect: viewModel.selectProduct
                    )
                    .padding(.bottom, PLSpacing.xl)
                }

                if viewModel.catalog.isEmpty {
                    HomeEmptyView()
                        .padding(.top, PLSpacing.xl)
                        .padding(.horizontal, PLSpacing.xl)
                } else {
                    CollectionGridSection(
                        products: viewModel.catalog,
                        columns: gridColumns,
                        onSelect: viewModel.selectProduct
                    )
                    .padding(.horizontal, PLSpacing.xl)
                }

                Spacer(minLength: PLSpacing.xxl)
            }
        }
        .scrollIndicators(.hidden)
        .refreshable { await viewModel.load() }
    }
}

// MARK: - Header

struct HomeHeaderView: View {

    let onNotifications: () -> Void
    let onCart: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Paintres Lumière")
                    .font(PLFont.h2())
                    .foregroundStyle(PLColor.goldBright)
                Text("BOUTIQUE")
                    .font(PLFont.label())
                    .foregroundStyle(PLColor.textMuted)
                    .tracking(2)
            }
            Spacer()
            HStack(spacing: PLSpacing.md) {
                Button("Notifications", systemImage: "bell", action: onNotifications)
                    .labelStyle(.iconOnly)
                Button("Cart", systemImage: "cart", action: onCart)
                    .labelStyle(.iconOnly)
            }
            .foregroundStyle(PLColor.textMuted)
            .font(.system(.title3))
        }
        .padding(.top, PLSpacing.sm)
    }
}

// MARK: - Popular section

struct PopularProductsSection: View {

    let products: [Product]
    let onSelect: (Product) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PLSpacing.md) {
            HStack {
                Text("MOST POPULAR")
                    .font(PLFont.label())
                    .foregroundStyle(PLColor.textMuted)
                    .tracking(1)
                Spacer()
            }
            .padding(.top, PLSpacing.lg)
            .padding(.horizontal, PLSpacing.xl)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: PLSpacing.md) {
                    ForEach(products) { product in
                        PLProductCard(product: product) { onSelect(product) }
                            .frame(width: 180)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, PLSpacing.xl, for: .scrollContent)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

// MARK: - Collection grid

struct CollectionGridSection: View {

    let products: [Product]
    let columns: [GridItem]
    let onSelect: (Product) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PLSpacing.md) {
            HStack {
                Text("OUR COLLECTION")
                    .font(PLFont.label())
                    .foregroundStyle(PLColor.textMuted)
                    .tracking(1)
                Spacer()
                Text("\(products.count) pieces")
                    .font(PLFont.caption())
                    .foregroundStyle(PLColor.textDisabled)
            }

            LazyVGrid(columns: columns, spacing: PLSpacing.md) {
                ForEach(products) { product in
                    PLProductCard(product: product) { onSelect(product) }
                }
            }
        }
    }
}

// MARK: - States

private struct HomeLoadingView: View {
    var body: some View {
        VStack(spacing: PLSpacing.md) {
            ProgressView()
                .tint(PLColor.goldMid)
            Text("Loading catalog…")
                .font(PLFont.body())
                .foregroundStyle(PLColor.textMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct HomeErrorView: View {
    let message: String
    let onRetry: () -> Void
    var body: some View {
        VStack(spacing: PLSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundStyle(PLColor.warning)
            Text("Couldn't load the catalog")
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

private struct HomeEmptyView: View {
    var body: some View {
        VStack(spacing: PLSpacing.md) {
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundStyle(PLColor.goldAntique)
            Text("Catalog is empty")
                .font(PLFont.h2())
                .foregroundStyle(PLColor.textPrimary)
            Text("New pieces will appear here as the seller adds them.")
                .font(PLFont.body())
                .foregroundStyle(PLColor.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PLSpacing.xxl)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    let viewModel = HomeViewModel(
        productService: PreviewProductService(),
        messages: PreviewMessagesService()
    )
    return HomeView(viewModel: viewModel)
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
