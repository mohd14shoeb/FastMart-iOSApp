//
//  KeychainWrapper.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 15/07/26.
//

import Foundation
import Security

// MARK: - Keychain Wrapper

/// Minimal Keychain wrapper — secure storage for tokens.
final class KeychainWrapper {

    static let shared = KeychainWrapper()

    private let service = "com.fastmart.ios"

    private init() {}

    // MARK: - Operations

    func string(forKey key: KeychainKey) -> String? {
        let query: [String: Any] = [
            kSecClass       as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData  as String: true,
            kSecMatchLimit  as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func set(_ value: String, forKey key: KeychainKey) {
        guard let data = value.data(using: .utf8) else { return }

        // Delete existing first
        let deleteQuery: [String: Any] = [
            kSecClass       as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new
        let addQuery: [String: Any] = [
            kSecClass       as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData   as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    func delete(forKey key: KeychainKey) {
        let query: [String: Any] = [
            kSecClass       as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Keychain Keys

enum KeychainKey: String {
    case authToken = "auth_token"
}
