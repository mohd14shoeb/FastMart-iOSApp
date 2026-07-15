//
//  SplashViewController.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 15/07/26.
//

import UIKit

final class SplashViewController: UIViewController {

    var onFinish: (() -> Void)?

    private let logoLabel = UILabel()
    private let appNameLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        logoLabel.text = "🛒"
        logoLabel.font = .systemFont(ofSize: 72)
        logoLabel.textAlignment = .center
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoLabel)

        appNameLabel.text = "FastMart"
        appNameLabel.font = .systemFont(ofSize: 32, weight: .bold)
        appNameLabel.textColor = .systemIndigo
        appNameLabel.textAlignment = .center
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appNameLabel)

        spinner.color = .systemIndigo
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),

            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appNameLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 16),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 40),
        ])

        spinner.startAnimating()

        animateIn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.onFinish?()
            }
        }
    }

    private func animateIn(completion: @escaping () -> Void) {
        logoLabel.alpha = 0
        logoLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        appNameLabel.alpha = 0

        UIView.animate(
            withDuration: 0.5, delay: 0.1,
            usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.logoLabel.alpha = 1
            self.logoLabel.transform = .identity
            self.appNameLabel.alpha = 1
        } completion: { _ in completion() }
    }
}
