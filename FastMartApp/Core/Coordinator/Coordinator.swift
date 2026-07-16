import UIKit

// MARK: - Base Coordinator Protocol
@MainActor
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}

@MainActor
protocol RoutableCoordinator: Coordinator {

    associatedtype Route

    var onFinish: (() -> Void)? { get set }

    func navigate(to route: Route)
}
