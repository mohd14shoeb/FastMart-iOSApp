//
//  SettingsViewModel.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 16/07/26.
//

import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {

    @Published var notificationsEnabled: Bool
    @Published var selectedAppearance: Appearance

    var onChangePassword: (() -> Void)?
    var onPrivacyPolicy: (() -> Void)?
    var onAbout: (() -> Void)?

    init(
        notificationsEnabled: Bool = true,
        selectedAppearance: Appearance = .system
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.selectedAppearance = selectedAppearance
    }

    func changePasswordTapped() {
        onChangePassword?()
    }

    func privacyPolicyTapped() {
        onPrivacyPolicy?()
    }

    func aboutTapped() {
        onAbout?()
    }
}

enum Appearance: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String {
        rawValue
    }
}
