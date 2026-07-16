//
//  HostingControllerFactory.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 16/07/26.
//

import SwiftUI
import UIKit


@MainActor
final class FlowHostingController<Content: View>:
    UIHostingController<Content> {

    var onRemovedFromNavigation: (() -> Void)?

    private var wasAddedToParent = false
    private var didReportRemoval = false

    override func didMove(
        toParent parent: UIViewController?
    ) {
        super.didMove(toParent: parent)

        if parent != nil {
            wasAddedToParent = true
            return
        }

        guard
            wasAddedToParent,
            !didReportRemoval
        else {
            return
        }

        didReportRemoval = true
        onRemovedFromNavigation?()
    }
}

enum HostingControllerFactory {

    static func make<Content: View>(
        rootView: Content,
        hidesBottomBar: Bool = true,
        backgroundColor: UIColor = .systemBackground
    ) -> FlowHostingController<Content> {

        let controller = FlowHostingController(
            rootView: rootView
        )

        controller.hidesBottomBarWhenPushed =
            hidesBottomBar

        controller.view.backgroundColor =
            backgroundColor

        return controller
    }
}
