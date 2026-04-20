import UIKit

// MARK: - HomeViewController

/// Thin UIViewController that hosts HomeView.
final class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUI(HomeView())
    }
}
