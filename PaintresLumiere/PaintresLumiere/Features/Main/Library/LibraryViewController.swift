import UIKit

// MARK: - LibraryViewController

/// Thin UIViewController that hosts LibraryView.
final class LibraryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUI(LibraryView())
    }
}
