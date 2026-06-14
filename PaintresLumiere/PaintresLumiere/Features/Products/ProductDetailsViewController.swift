import UIKit

// MARK: - ProductDetailsViewController

/// Thin UIViewController that hosts ProductDetailsView. Owns the ViewModel
/// lifecycle. Shows its own nav bar so the user can dismiss back to Home.
final class ProductDetailsViewController: UIViewController {

    private let viewModel: ProductDetailsViewModel

    init(viewModel: ProductDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PLColor.UI.backgroundPrimary
        embedSwiftUI(ProductDetailsView(viewModel: viewModel))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the parent nav bar — the SwiftUI view draws its own back chevron
        // over the image carousel for a more immersive feel.
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
