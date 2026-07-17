//
//  SecurityBlockedViewController.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 17/07/26.
//

import UIKit

final class SecurityBlockedViewController:
    UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground

        let imageView = UIImageView(
            image: UIImage(
                systemName: "lock.trianglebadge.exclamationmark"
            )
        )

        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(
                equalToConstant: 72
            ),
            imageView.widthAnchor.constraint(
                equalToConstant: 72
            )
        ])

        let titleLabel = UILabel()
        titleLabel.text = "Device Not Supported"
        titleLabel.font = .preferredFont(
            forTextStyle: .title2
        )
        titleLabel.textAlignment = .center

        let messageLabel = UILabel()
        messageLabel.text = """
        This app cannot run because the device \
        does not meet the required security conditions.
        """
        messageLabel.font = .preferredFont(
            forTextStyle: .body
        )
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let stackView = UIStackView(
            arrangedSubviews: [
                imageView,
                titleLabel,
                messageLabel
            ]
        )

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints =
            false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 32
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -32
            ),
            stackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])
    }
}
