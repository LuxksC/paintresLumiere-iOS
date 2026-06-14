import UIKit

// MARK: - HomeViewController

/// Thin UIViewController that hosts HomeView. Owns the ViewModel lifecycle.
final class HomeViewController: UIViewController {

    private let viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUI(HomeView(viewModel: viewModel))
    }
}
