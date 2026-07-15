import UIKit

// MARK: - App Coordinator (Root)

final class AppCoordinator: Coordinator {
    
    // MARK: - Properties
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // Global side-menu state so every screen can toggle it
    private var sideMenuController: SideMenuViewController?
    
    // Cache credentials → auto-login next launch
    private let session = SessionStore.shared
    // MARK: - Init
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Start
    func start() {
        showSplashScreen()
    }

    private func showSplashScreen() {
        let splashVC = SplashViewController()
        splashVC.onFinish = { [weak self] in
            if self?.session.isLoggedIn == true {
                self?.loadDashboardAndShow()
            } else {
                self?.showAuthFlow()
            }
        }
        navigationController.setViewControllers([splashVC], animated: false)
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
    
    private func showMainFlow(with data: DashboardPrefetcher.DashboardData? = nil) {
        let mainCoordinator = MainCoordinator(
            navigationController: navigationController,
            prefetchedData: data
        )
        mainCoordinator.onLogout = { [weak self] in
            self?.removeChild(mainCoordinator)
            self?.logout()
            self?.showAuthFlow()
        }
        addChild(mainCoordinator)
        mainCoordinator.start()
        
        LoadingIndicator.shared.hide()
    }
    
    func showMainFlow() {
        loadDashboardAndShow()
    }
    
    // MARK: - Logout
    
    func logout() {
        session.clearAll()
        navigationController.popToRootViewController(animated: false)
    }
    
    // MARK: - Helpers
    
}
extension AppCoordinator {
    // MARK: - Dashboard Loading (blocks until data arrives)
    
    private func loadDashboardAndShow() {
        Task {
            do {
                guard let data = try await DashboardPrefetcher().fetchAll() else {
                    self.showMainFlow(with: nil)
                    return
                }
                await MainActor.run {
                    self.showMainFlow(with: data)
                }
            } catch {
                await MainActor.run {
                    LoadingIndicator.shared.hide()
                    logError("Dashboard pre-fetch failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
