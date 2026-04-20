// Base protocol for all coordinators. Each coordinator owns its navigation
// controller (or tab bar controller) and is responsible for starting its flow.

import UIKit

protocol Coordinator: AnyObject {
    func start()
}
