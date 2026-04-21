import UIKit

// MARK: - SignUpViewController

/// Thin UIViewController that hosts SignUpView. Owns the ViewModel lifecycle.
/// Has no knowledge of coordinators — the ViewModel handles all navigation events.
final class SignUpViewController: UIViewController {

    private let viewModel: SignUpViewModel

    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUI(SignUpView(viewModel: viewModel))
    }
}
