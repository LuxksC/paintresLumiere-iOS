import UIKit

// MARK: - ForgotPasswordViewController

/// Thin UIViewController that hosts ForgotPasswordView. Owns the ViewModel lifecycle.
/// Has no knowledge of coordinators — the ViewModel handles all navigation events.
final class ForgotPasswordViewController: UIViewController {

    private let viewModel: ForgotPasswordViewModel

    init(viewModel: ForgotPasswordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUI(ForgotPasswordView(viewModel: viewModel))
    }
}
