//
//  UserProfileCache.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 17/07/26.
//


import Foundation


final class UserProfileCache {
    
    static let shared = UserProfileCache()
    let userId = SessionStore.shared.userId
    
    
    private enum CacheKey {
        static let userProfile = "user_profile_response"
    }
    
    private let rawCache: RawCache
    
    private init(rawCache: RawCache = .shared) {
        self.rawCache = rawCache
    }
    
    // MARK: - User
    
    func saveUser(_ user: User) async {
        await rawCache.save(user, forKey: CacheKey.userProfile)
    }
    
    func getUser() -> User? {
        rawCache.load(User.self, forKey: CacheKey.userProfile)
    }
    
    func removeUser() {
        rawCache.remove(forKey: CacheKey.userProfile)
    }
    
    // MARK: - Dashboard logout cleanup
    
    func clear() {
        removeUser()
    }
}
