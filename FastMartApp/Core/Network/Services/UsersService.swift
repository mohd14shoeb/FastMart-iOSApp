//
//  UsersService.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 15/07/26.
//

import Foundation

// MARK: - Product Service Protocol

protocol UsersServiceProtocol {
    func fetchUser(userId: String) async throws -> User
//    func fetchProductDetail(id: String) async throws -> ProductDTO
//    func search(query: String, page: Int) async throws -> [ProductDTO]
}

// MARK: - Product Service Implementation

final class UsersService: UsersServiceProtocol {
    
    static let shared = UsersService()
    private let client = APIClient.shared
    
    func fetchUser(userId: String) async throws -> User {
        try await client.request(UsersEndpoints.getUserProfileDetails(userID: userId))
    }
    
}
