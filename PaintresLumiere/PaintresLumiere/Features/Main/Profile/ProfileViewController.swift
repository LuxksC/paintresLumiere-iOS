import UIKit

// MARK: - ProfileViewController

/// Thin UIViewController that hosts ProfileView. Owns the ViewModel lifecycle.
/// Has no knowledge of coordinators — the ViewModel handles all navigation events.
final class ProfileViewController: UIViewController {

    private let viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUI(ProfileView(viewModel: viewModel))
    }
}
