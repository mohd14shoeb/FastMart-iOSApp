//
//  ProfileCoordinator.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 16/07/26.
//

import UIKit
import SwiftUI



enum ProfileRoute: Equatable {
    case showProfile
    case editProfile
    case changePassword
}

@MainActor
final class ProfileCoordinator: BaseCoordinator, RoutableCoordinator {
    
    private let userService: UsersServiceProtocol
    typealias Route = ProfileRoute
    var onLogout: (() -> Void)?
    var onFinish: (() -> Void)?
    init(
        navigationController: UINavigationController,
        userService: UsersServiceProtocol
    ) {
        self.userService = userService
        super.init(navigationController: navigationController)
        print("✅ ProfileCoordinator initialized")
    }
    
    func navigate(to route: ProfileRoute) {
        switch route {
        case .showProfile:
            showProfile()
            
        case .editProfile: break
            // showEditProfile()
            
        case .changePassword: break
        }
    }
    
    //    private func showEditProfile() {
    //        // This destination can be UIKit or SwiftUI.
    //let viewController = EditProfileViewController()
    //navigationController.pushViewController(viewController, animated: true)
    //    }
    
    
    isolated deinit {
        print("❌ ProfileCoordinator deinitialized")
    }
    
    func finish() {
        print("ProfileCoordinator finished")
        onFinish?()
    }
}

private extension ProfileCoordinator {
    
    func showProfile() {
        let viewModel = ProfileViewModel(userService: userService)
        
        viewModel.onEditProfile = { [weak self] in
            self?.navigate(to: .editProfile)
        }
        
        viewModel.onOpenSettings = { [weak self] in
            guard let self else { return }
            self.showSettings()
        }
        
        let profileView = ProfileView(viewModel: viewModel)
        
        let hostingController = HostingControllerFactory.make(rootView: profileView)
        hostingController.onRemovedFromNavigation = { [weak self] in
                self?.onFinish?()
            }
        navigationController.addCustomBackButton()
        
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    private func showSettings() {
        print("showSettings hello its getting called ")
      
        self.startChild(route: SettingsRoute.showSttings) { [userService] navigationController in
            SettingsCoordinator(navigationController: navigationController, userService: userService)
        }
    }
    
    @objc private func customBackAction() {
        // Handle custom back button action here
        print("Back button tapped")
    }
}

