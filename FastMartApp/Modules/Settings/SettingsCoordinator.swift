//
//  SettingsCoordinator.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 16/07/26.
//


import UIKit
import SwiftUI



enum SettingsRoute: Equatable {
    case showSttings
    case editProfile
    case changePassword
}

@MainActor
final class SettingsCoordinator: BaseCoordinator, RoutableCoordinator {
    
    private let userService: UsersServiceProtocol
    typealias Route = SettingsRoute
    var onLogout: (() -> Void)?
    var onFinish: (() -> Void)?
    
    init(
        navigationController: UINavigationController,
        userService: UsersServiceProtocol
    ) {
        self.userService = userService
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        //  navigate(to: initialRoute)
    }
    
    func navigate(to route: SettingsRoute) {
        switch route {
        case .showSttings:
            showSettings()
        default: break
            
        }
    }
}
extension SettingsCoordinator {
    private func showSettings() {
        let viewModel = SettingsViewModel()
        
        let rootView = SettingsView(viewModel: viewModel)
        
        let hostingController = HostingControllerFactory.make(rootView: rootView)
        hostingController.onRemovedFromNavigation = { [weak self] in
            self?.onFinish?()
        }
        navigationController.addCustomBackButton()
        navigationController.pushViewController(hostingController, animated: true)
    }
    
}
