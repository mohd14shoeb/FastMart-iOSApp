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
                let user = try await userService.fetchUser(userId: "1")
                name = user.name ?? ""
                email = user.email ?? ""
                hasLoadedProfile = true
            } catch {
                errorMessage = error.localizedDescription
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
