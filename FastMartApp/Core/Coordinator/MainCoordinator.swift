import UIKit

// MARK: - Main Coordinator

final class MainCoordinator: Coordinator {

    // MARK: - Properties

    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    var onLogout: (() -> Void)?

    private var tabBarController: UITabBarController?
    private var sideMenuVC: SideMenuViewController?
    private var isSideMenuOpen = false
    private var overlayView: UIView?
    private var sideMenuWidth: CGFloat { 280 }
    private var currentTabIndex = 0

    // MARK: - Init

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Start

    func start() {
        showDashboard()
    }

    // MARK: - Dashboard with Tab Bar + Side Menu

    func showDashboard() {
        // ── Tab ViewModels ──────────────────────────────────────────
        let homeVM     = HomeViewModel()
        let cartVM     = CartViewModel()
        let servicesVM = ServicesViewModel()
        let helpVM     = HelpViewModel()

        // ── Tab ViewControllers embedded in their own NavControllers ──
        let homeNav     = makeNav(HomeViewController(viewModel: homeVM),
                                  icon: "house.fill",      title: "Home")
        let cartNav     = makeNav(CartViewController(viewModel: cartVM),
                                  icon: "cart.fill",       title: "Cart")
        let servicesNav = makeNav(ServicesViewController(viewModel: servicesVM),
                                  icon: "square.grid.2x2.fill", title: "Services")
        let helpNav     = makeNav(HelpViewController(viewModel: helpVM),
                                  icon: "questionmark.circle.fill", title: "Help")

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [homeNav, cartNav, servicesNav, helpNav]
        tabBarController.tabBar.backgroundColor = .systemBackground
        tabBarController.tabBar.tintColor = .systemIndigo
        tabBarController.delegate = self
        self.tabBarController = tabBarController

        // ── Side Menu ───────────────────────────────────────────────
        let sideMenuVM = SideMenuViewModel()
        sideMenuVM.onSelect = { [weak self] item in
            self?.handleSideMenuItem(item)
        }
        sideMenuVM.onLogout = { [weak self] in
            self?.closeSideMenu()
            self?.onLogout?()
        }

        let sideMenu = SideMenuViewController(viewModel: sideMenuVM)
        self.sideMenuVC = sideMenu

        // ── Hamburger button on every tab's nav bar ─────────────────
        addMenuButton(to: homeNav)
        addMenuButton(to: cartNav)
        addMenuButton(to: servicesNav)
        addMenuButton(to: helpNav)

        // ── Put tab bar inside the root nav controller ──────────────
        navigationController.setViewControllers([tabBarController], animated: false)

        // ── Add side menu as a child of the top-most view ──────────
        setupSideMenuGesture()
    }

    // MARK: - Side Menu Toggle

    func toggleSideMenu() {
        isSideMenuOpen ? closeSideMenu() : openSideMenu()
    }

    private func openSideMenu() {
        guard let tabVC = tabBarController,
              let menuVC = sideMenuVC else { return }

        // ── Overlay ─────────────────────────────────────────────────
        let overlay = UIView(frame: tabVC.view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        overlay.tag = 999
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeSideMenu))
        overlay.addGestureRecognizer(tap)
        tabVC.view.addSubview(overlay)
        self.overlayView = overlay

        // ── Add menu ────────────────────────────────────────────────
        tabVC.addChild(menuVC)
        menuVC.view.frame = CGRect(
            x: -sideMenuWidth, y: 0,
            width: sideMenuWidth, height: tabVC.view.bounds.height
        )
        tabVC.view.addSubview(menuVC.view)
        menuVC.didMove(toParent: tabVC)

        // ── Animate in ──────────────────────────────────────────────
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0,
            options: .curveEaseInOut
        ) {
            menuVC.view.frame.origin.x = 0
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }

        isSideMenuOpen = true
    }

    @objc func closeSideMenu() {
        guard let menuVC = sideMenuVC else { return }

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseIn
        ) { [weak self] in
            guard let self else { return }
            menuVC.view.frame.origin.x = -self.sideMenuWidth
            self.overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        } completion: { [weak self] _ in
            menuVC.willMove(toParent: nil)
            menuVC.view.removeFromSuperview()
            menuVC.removeFromParent()
            self?.overlayView?.removeFromSuperview()
            self?.overlayView = nil
            self?.isSideMenuOpen = false
        }
    }

    // MARK: - Side Menu Actions

    private func handleSideMenuItem(_ item: SideMenuItem) {
        closeSideMenu()
        switch item {
        case .home:      tabBarController?.selectedIndex = 0
        case .cart:      tabBarController?.selectedIndex = 1
        case .services:  tabBarController?.selectedIndex = 2
        case .help:      tabBarController?.selectedIndex = 3
        case .profile:   break // Push profile screen (out of scope)
        case .settings:  break
        case .about:     break
        }
    }

    // MARK: - Helpers

    private func makeNav(_ root: UIViewController,
                         icon: String, title: String) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            selectedImage: UIImage(systemName: icon)
        )
        return nav
    }

    private func addMenuButton(to nav: UINavigationController) {
        guard let firstVC = nav.viewControllers.first else { return }
        firstVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal"),
            style: .plain,
            target: self,
            action: #selector(menuTapped)
        )
    }

    @objc private func menuTapped() {
        toggleSideMenu()
    }

    private func setupSideMenuGesture() {
        let edgePan = UIScreenEdgePanGestureRecognizer(
            target: self, action: #selector(handleEdgePan(_:))
        )
        edgePan.edges = .left
        navigationController.view.addGestureRecognizer(edgePan)
    }

    @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard !isSideMenuOpen else { return }
        if gesture.state == .recognized {
            openSideMenu()
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension MainCoordinator: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        currentTabIndex = tabBarController.selectedIndex
        if isSideMenuOpen { closeSideMenu() }
    }
}
