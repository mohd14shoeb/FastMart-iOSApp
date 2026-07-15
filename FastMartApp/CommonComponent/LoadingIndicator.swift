//
//  LoadingIndicator.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 15/07/26.
//
import UIKit

// MARK: - Loading Indicator

final class LoadingIndicator {

    // MARK: - Singleton

    static let shared = LoadingIndicator()

    // MARK: - Properties

    private var overlayView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    private var isShowing: Bool { overlayView != nil }

    // MARK: - Init

    private init() {}

    // MARK: - Show (with optional message)

    /// Show loading overlay on the key window.
    func show(message: String? = nil) {
        guard !isShowing, let window = keyWindow else { return }

        // ── Overlay ─────────────────────────────────────────────────
        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        overlay.alpha = 0
        window.addSubview(overlay)
        self.overlayView = overlay

        // ── Container ───────────────────────────────────────────────
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.15
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.shadowRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(container)

        // ── Spinner ─────────────────────────────────────────────────
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .systemIndigo
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(spinner)
        self.activityIndicator = spinner

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),

            spinner.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: container.topAnchor, constant: 28),
        ])

        // ── Optional message ────────────────────────────────────────
        if let message = message {
            let label = UILabel()
            label.text = message
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)

            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16),
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            ])
        } else {
            NSLayoutConstraint.activate([
                spinner.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -28),
            ])
        }

        // ── Animate in ──────────────────────────────────────────────
        UIView.animate(withDuration: 0.25) {
            overlay.alpha = 1
        }

        // ── Background task (prevents suspension during long calls) ──
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            self?.hide()
        })
    }

    // MARK: - Hide

    func hide() {
        guard let overlay = overlayView else { return }

        UIView.animate(withDuration: 0.2, animations: {
            overlay.alpha = 0
        }, completion: { _ in
            overlay.removeFromSuperview()
            self.overlayView = nil
            self.activityIndicator = nil
        })

        // End background task
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }

    // MARK: - Helper

    private var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

// MARK: - Convenience async wrapper

extension LoadingIndicator {

    /// Show a loading indicator while performing an async task.
    /// Hides automatically when the task completes or throws.
    func perform<T>(message: String? = nil, _ task: @escaping () async throws -> T) async rethrows -> T {
        await MainActor.run { show(message: message) }
        defer { Task { @MainActor in hide() } }
        return try await task()
    }
}

