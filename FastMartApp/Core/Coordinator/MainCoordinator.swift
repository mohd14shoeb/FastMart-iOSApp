import UIKit

enum sideMenuRoute: Equatable {
    case setting
    case profile
    
}

// MARK: - Tab Item Enum

enum TabItem: Int, CaseIterable {
    case home     = 0
    case cart     = 1
    case services = 2
    case help     = 3

    var icon: String {
        switch self {
        case .home:     return "house.fill"
        case .cart:     return "cart.fill"
        case .services: return "square.grid.2x2.fill"
        case .help:     return "questionmark.circle.fill"
        }
    }

    var title: String {
        switch self {
        case .home:     return "Home"
        case .cart:     return "Cart"
        case .services: return "Services"
        case .help:     return "Help"
        }
    }

    var emoji: String {
        switch self {
        case .home:     return "🏠"
        case .cart:     return "🛒"
        case .services: return "🔧"
        case .help:     return "❓"
        }
    }
}

// MARK: - Main Coordinator

final class MainCoordinator: BaseCoordinator, UITabBarControllerDelegate {

    var onLogout: (() -> Void)?
    
    private let prefetchedData: DashboardPrefetcher.DashboardData?
    private var tabBarController: UITabBarController?
    private var sideMenuVC: SideMenuViewController?
    private var isSideMenuOpen = false
    private var overlayView: UIView?
    private let sideMenuWidth: CGFloat = 280
  
    init(navigationController: UINavigationController, prefetchedData: DashboardPrefetcher.DashboardData? = nil) {
        self.prefetchedData = prefetchedData
        super.init(navigationController: navigationController)
    }

    override func start() {
        showDashboard()
    }

    // MARK: - Dashboard with Tab Bar + Side Menu

    func showDashboard() {
 
        let homeNav     = makeNav(HomeViewController(),     icon: TabItem.home.icon,     title: TabItem.home.title)
        let cartNav     = makeNav(CartViewController(),     icon: TabItem.cart.icon,     title: TabItem.cart.title)
        let servicesNav = makeNav(ServicesViewController(), icon: TabItem.services.icon, title: TabItem.services.title)
        let helpNav     = makeNav(HelpViewController(),     icon: TabItem.help.icon,     title: TabItem.help.title)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [homeNav, cartNav, servicesNav, helpNav]
        tabBarController.tabBar.backgroundColor = .systemBackground
        tabBarController.tabBar.tintColor = .systemIndigo
        tabBarController.delegate = self
        self.tabBarController = tabBarController

        // ── Side Menu ───────────────────────────────────────────────
      
        let sideMenuVM = SideMenuViewModel(user: prefetchedData?.user)
        sideMenuVM.onSelect = { [weak self] item in
            self?.handleSideMenuItem(item)
        }
        sideMenuVM.onLogout = { [weak self] in
            self?.closeSideMenu()
            self?.onLogout?()
        }
        let sideMenu = SideMenuViewController(viewModel: sideMenuVM)
        self.sideMenuVC = sideMenu

        // Hamburger button on every tab
        [homeNav, cartNav, servicesNav, helpNav].forEach { addMenuButton(to: $0) }

        navigationController.setViewControllers([tabBarController], animated: false)
        setupSideMenuGesture()
    }

    // MARK: - Side Menu Toggle

    func toggleSideMenu() {
        isSideMenuOpen ? closeSideMenu() : openSideMenu()
    }

    private func openSideMenu() {
        guard let tabVC = tabBarController, let menuVC = sideMenuVC else { return }

        let overlay = UIView(frame: tabVC.view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        overlay.tag = 999
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeSideMenu))
        overlay.addGestureRecognizer(tap)
        tabVC.view.addSubview(overlay)
        self.overlayView = overlay

        tabVC.addChild(menuVC)
        menuVC.view.frame = CGRect(x: -sideMenuWidth, y: 0, width: sideMenuWidth, height: tabVC.view.bounds.height)
        tabVC.view.addSubview(menuVC.view)
        menuVC.didMove(toParent: tabVC)

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .curveEaseInOut) {
            menuVC.view.frame.origin.x = 0
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
        isSideMenuOpen = true
    }

    @objc func closeSideMenu() {
        guard let menuVC = sideMenuVC else { return }

        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self else { return }
            menuVC.view.frame.origin.x = -self.sideMenuWidth
            self.overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        } completion: { _ in
            menuVC.willMove(toParent: nil)
            menuVC.view.removeFromSuperview()
            menuVC.removeFromParent()
            self.overlayView?.removeFromSuperview()
            self.overlayView = nil
            self.isSideMenuOpen = false
        }
    }

    // MARK: - Side Menu Actions

    private func handleSideMenuItem(_ item: SideMenuItem) {
        closeSideMenu()
        switch item {
        case .home:
            switchToTab(.home)
        case .cart:
            switchToTab(.cart)
        case .services:
            switchToTab(.services)
        case .help:
            switchToTab(.help)
        case .profile:
            startProfileFlow(route: .showProfile)
        case .settings:
            self.startSettingsFlow(route: .showSttings)
        case .about:
            pushSkeletonScreen(title: "ℹ️ About", supportsTabSwitch: true)
        }
    }

    // MARK: - Tab Switching (callable from any pushed screen)

    func switchToTab(_ tab: TabItem) {
        // 1. Pop the current tab to root so no stale screens remain
        popCurrentTabToRoot()
        // 2. Switch to the desired tab
        tabBarController?.selectedIndex = tab.rawValue
    }

    private func popCurrentTabToRoot() {
        guard let nav = tabBarController?.selectedViewController as? UINavigationController else { return }
        nav.popToRootViewController(animated: false)
    }

    // MARK: - Push Skeleton Screen

    private func pushSkeletonScreen(title: String, supportsTabSwitch: Bool = false) {
        guard let nav = tabBarController?.selectedViewController as? UINavigationController else { return }

        let vc = UIViewController()
        vc.view.backgroundColor = .systemGroupedBackground
        vc.title = title
        vc.hidesBottomBarWhenPushed = true

        // Show the nav bar for back button
        nav.setNavigationBarHidden(false, animated: false)

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
        ])

        // ── Optional: Add tab switching buttons ────────────────────
        if supportsTabSwitch {
            addTabSwitchButtons(to: vc)
        }

        nav.pushViewController(vc, animated: true)
    }

    /// Adds buttons to jump to any tab from the pushed skeleton screen.
    private func addTabSwitchButtons(to vc: UIViewController) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        for tab in TabItem.allCases {
            let btn = UIButton(type: .system)
            btn.setTitle("\(tab.emoji) Go to \(tab.title)", for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            btn.tag = tab.rawValue
            btn.addTarget(self, action: #selector(tabSwitchButtonTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
        }

        vc.view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            stack.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 80),
        ])
    }

    @objc private func tabSwitchButtonTapped(_ sender: UIButton) {
        guard let tab = TabItem(rawValue: sender.tag) else { return }
        switchToTab(tab)
    }

    // MARK: - Helpers

    private func makeNav(_ root: UIViewController, icon: String, title: String) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), selectedImage: UIImage(systemName: icon))
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

    @objc private func menuTapped() { toggleSideMenu() }

    private func setupSideMenuGesture() {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        edgePan.edges = .left
        navigationController.view.addGestureRecognizer(edgePan)
    }

    @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard !isSideMenuOpen, gesture.state == .recognized else { return }
        openSideMenu()
    }
}

// MARK: - UITabBarControllerDelegate

extension MainCoordinator {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if isSideMenuOpen { closeSideMenu() }
    }
}

extension MainCoordinator {

    private func startProfileFlow(route: ProfileRoute) {
        guard let selectedNavigationController =
            tabBarController?.selectedViewController as? UINavigationController else {
              debugPrint("Selected tab must be a UINavigationController.")
            
            return
        }
        let userService = UsersService.shared
        startChild(route: route, on: selectedNavigationController) { [userService] navigationController in
            ProfileCoordinator(navigationController: navigationController, userService:  userService)
        }
    }
    private func startSettingsFlow(route: SettingsRoute) {
        guard let selectedNavigationController =
            tabBarController?.selectedViewController as? UINavigationController else {
              debugPrint("Selected tab must be a UINavigationController.")
            
            return
        }
        let userService = UsersService.shared
        startChild(route: route, on: selectedNavigationController) { [userService] navigationController in
            SettingsCoordinator(navigationController: navigationController, userService:  userService)
        }
    }
}
