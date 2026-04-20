import UIKit

// MARK: - LoginViewController

/// Thin UIViewController that hosts LoginView. Owns the ViewModel lifecycle.
/// Has no knowledge of coordinators — the ViewModel handles all navigation events.
final class LoginViewController: UIViewController {

    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUI(LoginView(viewModel: viewModel))
    }
}
