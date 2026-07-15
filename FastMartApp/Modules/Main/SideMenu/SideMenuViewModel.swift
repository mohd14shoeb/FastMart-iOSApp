import Foundation

// MARK: - Side Menu Item Enum

enum SideMenuItem: CaseIterable {
    case home
    case cart
    case services
    case help
    case profile
    case settings
    case about

    var title: String {
        switch self {
        case .home:      return "Home"
        case .cart:      return "Cart"
        case .services:  return "Services"
        case .help:      return "Help"
        case .profile:   return "Profile"
        case .settings:  return "Settings"
        case .about:     return "About"
        }
    }

    var icon: String {
        switch self {
        case .home:      return "house.fill"
        case .cart:      return "cart.fill"
        case .services:  return "square.grid.2x2.fill"
        case .help:      return "questionmark.circle.fill"
        case .profile:   return "person.fill"
        case .settings:  return "gearshape.fill"
        case .about:     return "info.circle.fill"
        }
    }
}

// MARK: - SideMenu ViewModel

final class SideMenuViewModel {
    
    struct SideMenuSection {
        let title: String
        let items: [SideMenuItem]
    }
    
    let sections: [SideMenuSection] = [
        SideMenuSection(title: "Navigation", items: [.home, .cart, .services, .help]),
        SideMenuSection(title: "Account",    items: [.profile, .settings]),
        SideMenuSection(title: "Other",      items: [.about]),
    ]
    
    private let user: User?
    init(user: User?) {
        self.user = user
    }
    var userName: String {
        self.user?.name ?? ""
    }
    var userEmail: String {
        self.user?.email ?? ""
    }
    
    var onSelect: ((SideMenuItem) -> Void)?
    var onLogout: (() -> Void)?
}
