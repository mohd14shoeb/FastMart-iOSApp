import UIKit

// MARK: - Auth Coordinator

final class AuthCoordinator: Coordinator {

    // MARK: - Properties

    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    var onLoginSuccess: (() -> Void)?

    // MARK: - Init

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Start

    func start() {
        showLogin()
    }

    // MARK: - Screens

    func showLogin() {
        let vm = LoginViewModel(authService: AuthService())
        vm.onLoginSuccess = { [weak self] in
            self?.onLoginSuccess?()
        }
        vm.onForgotPassword = { [weak self] in
            self?.showForgotPassword()
        }

        let vc = LoginViewController(viewModel: vm)
        navigationController.setViewControllers([vc], animated: false)
    }

    func showForgotPassword() {
        let vm = ForgotPasswordViewModel()
        vm.onBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        vm.onResetSent = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        let vc = ForgotPasswordViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}
