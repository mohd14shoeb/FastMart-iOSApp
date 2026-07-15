//
//  SessionStore.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 15/07/26.
//

import Foundation

// MARK: - Session Store

/// Central persistence layer.
/// Tokens go to Keychain, everything else to UserDefaults.
/// Inject anywhere: coordinators, services, view models.
final class SessionStore {

    static let shared = SessionStore()

    private let defaults = UserDefaults.standard
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {}

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Auth Token (Keychain)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    var authToken: String? {
        get { KeychainWrapper.shared.string(forKey: .authToken) }
        set {
            if let token = newValue {
                KeychainWrapper.shared.set(token, forKey: .authToken)
            } else {
                KeychainWrapper.shared.delete(forKey: .authToken)
            }
        }
    }

    var isLoggedIn: Bool { authToken != nil }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - User Profile (UserDefaults)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func saveUser(_ response: LoginResponse) {
        defaults.set(response.userId,   forKey: .userId)
        defaults.set(response.userName, forKey: .userName)
        defaults.set(response.tokenType, forKey: .tokenType)
    }

    var userId: Int?       { defaults.object(forKey: .userId) as? Int }
    var userName: String?  { defaults.string(forKey: .userName) }
    var tokenType: String? { defaults.string(forKey: .tokenType) }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Generic Codable Caching (UserDefaults)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func save<T: Encodable>(_ object: T, forKey key: StorageKey) {
        guard let data = try? encoder.encode(object) else { return }
        defaults.set(data, forKey: key.rawValue)
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: StorageKey) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    func remove(forKey key: StorageKey) {
        defaults.removeObject(forKey: key.rawValue)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Clear All (Logout)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func clearAll() {
        authToken = nil
        StorageKey.allCases.forEach { defaults.removeObject(forKey: $0.rawValue) }
        defaults.removeObject(forKey: .userId)
        defaults.removeObject(forKey: .userName)
        defaults.removeObject(forKey: .tokenType)
    }
}

// MARK: - Storage Keys

enum StorageKey: String, CaseIterable {
    case dashboardCache = "cached_dashboard"
    case cartCache      = "cached_cart"
    case servicesCache  = "cached_services"
    case lastFetchDate  = "last_fetch_date"
}

// MARK: - UserDefaults Key Helpers

private extension String {
    static let userId    = "session_user_id"
    static let userName  = "session_user_name"
    static let tokenType = "session_token_type"
}
