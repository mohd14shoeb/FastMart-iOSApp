import UIKit

// MARK: - App Coordinator (Root)

final class AppCoordinator: Coordinator {

    // MARK: - Properties

    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    // Global side-menu state so every screen can toggle it
    private var sideMenuController: SideMenuViewController?

    // Cache credentials → auto-login next launch
    private let defaults = UserDefaults.standard

    // MARK: - Init

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Start

    func start() {
        if isLoggedIn {
            showMainFlow()
        } else {
            showAuthFlow()
        }
    }

    // MARK: - Auth Flow

    func showAuthFlow() {
        let authCoordinator = AuthCoordinator(
            navigationController: navigationController
        )
        authCoordinator.onLoginSuccess = { [weak self] in
            self?.removeChild(authCoordinator)
            self?.showMainFlow()
        }
        addChild(authCoordinator)
        authCoordinator.start()
    }

    // MARK: - Main Flow

    func showMainFlow() {
        let mainCoordinator = MainCoordinator(
            navigationController: navigationController
        )
        mainCoordinator.onLogout = { [weak self] in
            self?.removeChild(mainCoordinator)
            self?.logout()
            self?.showAuthFlow()
        }
        addChild(mainCoordinator)
        mainCoordinator.start()
    }

    // MARK: - Logout

    func logout() {
        defaults.removeObject(forKey: "auth_token")
        navigationController.popToRootViewController(animated: false)
    }

    // MARK: - Helpers

    private var isLoggedIn: Bool {
        defaults.string(forKey: "auth_token") != nil
    }
}
