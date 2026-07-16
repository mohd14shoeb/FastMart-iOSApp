import UIKit

// MARK: - Auth Coordinator

final class AuthCoordinator: BaseCoordinator {

    // MARK: - Properties
    var onLoginSuccess: (() -> Void)?

    // MARK: - Init

    override init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
    }

    // MARK: - Start

    override func start() {
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
