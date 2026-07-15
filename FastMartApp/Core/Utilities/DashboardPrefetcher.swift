//
//  DashboardPrefetcher.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 15/07/26.
//

import Foundation

// MARK: - Dashboard Prefetcher

/// Fires all dashboard APIs in parallel and returns results.
/// Call once after login — user stays on login screen until data is ready.
/// 
final class DashboardPrefetcher {

    // Combine all results into one type so we can return them atomically.
    struct DashboardData {
        let user: User
      //  let cartData: CartResponse
    }

    enum PrefetchError: LocalizedError {
        case failed(String)

        var errorDescription: String? {
            if case .failed(let msg) = self { return msg }
            return nil
        }
    }

    private let userService: UsersServiceProtocol
    private let session = SessionStore.shared

    init(userService: UsersServiceProtocol = UsersService.shared) {
        self.userService = userService
    }

    /// Runs all fetches concurrently. Throws if ANY fail.
    func fetchAll() async throws -> DashboardData? {
        guard let userId = session.userId else {
            LoadingIndicator.shared.hide()
            return nil
        }
        async let user = userService.fetchUser(userId: String(userId))
        
        do {
            LoadingIndicator.shared.hide()
            let (user) = try await (user)
            await RawCache.shared.save(user, forKey: "user_profile_response")
          //  logSuccess("Dashboard data pre-fetched — \(user) items, \(user.addresses?.count ?? 0) cart items")
            return DashboardData(user: user)
        } catch {
            LoadingIndicator.shared.hide()
            logError("Dashboard pre-fetch failed: \(error.localizedDescription)")
            throw PrefetchError.failed(error.localizedDescription)
        }
    }
}

