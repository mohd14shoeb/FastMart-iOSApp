//
//  ProfileViewModel.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 16/07/26.
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published private(set) var name = ""
    @Published private(set) var email = ""
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let userService: UsersServiceProtocol
    var hasLoadedProfile: Bool = false
    var onEditProfile: (() -> Void)?
    var onOpenSettings: (() -> Void)?
    var onLogout: (() -> Void)?

    init(userService: UsersServiceProtocol) {
        self.userService = userService
    }

    // ProfileViewModel
    func loadProfile(forceRefresh: Bool = false) {
        Task {
            guard !isLoading else { return }
            guard forceRefresh || !hasLoadedProfile else { return }
            
            isLoading = true
            defer { isLoading = false }
            
            do {
                guard let user = UserProfileCache.shared.getUser() else { return }
                name = user.name ?? ""
                email = user.email ?? ""
                hasLoadedProfile = true
            }
        }
    }

    func editProfileTapped() {
        onEditProfile?()
    }

    func settingsTapped() {
        onOpenSettings?()
    }

    func logoutTapped() {
        onLogout?()
    }
}
