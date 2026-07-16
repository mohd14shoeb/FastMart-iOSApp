//
//  UINavigationController.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 16/07/26.
//

import UIKit

extension UINavigationController {
    func addCustomBackButton(title: String = "Back") {
        let backButton = UIBarButtonItem()
        backButton.title = title
        navigationBar.topItem?.backBarButtonItem = backButton
    }
}


