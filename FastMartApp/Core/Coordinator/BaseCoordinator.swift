//
//  BaseCoordinator.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 16/07/26.
//

import UIKit
import SwiftUI

@MainActor
class BaseCoordinator: NSObject, Coordinator {
    
    let navigationController: UINavigationController
    
    private var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    func start() {
        
        debugPrint("\(String(describing: type(of: self))) must implement start()")
        
    }
    
    // MARK: - Child coordinators
    
    final func addChild(_ coordinator: Coordinator) {
        guard !childCoordinators.contains(
            where: { $0 === coordinator }
        ) else {
            return
        }
        
        childCoordinators.append(coordinator)
    }
    
    final func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll {
            $0 === coordinator
        }
    }
    
    final func removeAllChildren() {
        childCoordinators.removeAll()
    }
    
    // MARK: - SwiftUI navigation
    
    @discardableResult
    final func pushSwiftUI<Content: View>(
        _ rootView: Content,
        animated: Bool = true,
        hidesBottomBar: Bool = false
    ) -> UIHostingController<Content> {
        let hostingController = UIHostingController(
            rootView: rootView
        )
        
        hostingController.hidesBottomBarWhenPushed = hidesBottomBar
        
        navigationController.pushViewController(
            hostingController,
            animated: animated
        )
        
        return hostingController
    }
    
    @discardableResult
    final func presentSwiftUI<Content: View>(
        _ rootView: Content,
        animated: Bool = true,
        presentationStyle: UIModalPresentationStyle = .pageSheet
    ) -> UIHostingController<Content> {
        let hostingController = UIHostingController(
            rootView: rootView
        )
        
        hostingController.modalPresentationStyle = presentationStyle
        
        navigationController.present(
            hostingController,
            animated: animated
        )
        
        return hostingController
    }
    
    final func pop(animated: Bool = true) {
        navigationController.popViewController(
            animated: animated
        )
    }
    
    final func popToRoot(animated: Bool = true) {
        navigationController.popToRootViewController(
            animated: animated
        )
    }
    
    final func dismiss(animated: Bool = true) {
        navigationController.dismiss(
            animated: animated
        )
    }
    
    @discardableResult
    final func startChild<C: RoutableCoordinator>(route: C.Route, on navigationController:
                                                  UINavigationController? = nil, onFinish: (() -> Void)? = nil, makeCoordinator: (UINavigationController) -> C) -> C {
        let targetNavigationController =
        navigationController ??
        self.navigationController
        
        let coordinator = makeCoordinator(
            targetNavigationController
        )
        
        coordinator.onFinish = {
            [weak self, weak coordinator] in
            
            guard
                let self,
                let coordinator
            else {
                return
            }
            
            self.removeChild(coordinator)
            onFinish?()
        }
        
        addChild(coordinator)
        coordinator.navigate(to: route)
        
        return coordinator
    }
}
