import Foundation

// MARK: - Cart Service Protocol

protocol CartServiceProtocol {
    func fetchCart() async throws -> CartResponse
    func addItem(productId: String, quantity: Int) async throws
    func removeItem(productId: String) async throws
    func updateQuantity(productId: String, quantity: Int) async throws
}

// MARK: - Cart Service Implementation

final class CartService: CartServiceProtocol {

    static let shared = CartService()
    private let client = APIClient.shared

    func fetchCart() async throws -> CartResponse {
        try await client.request(CartEndpoints.getCart)
    }

    func addItem(productId: String, quantity: Int) async throws {
        try await client.request(CartEndpoints.addItem(productId: productId, quantity: quantity))
    }

    func removeItem(productId: String) async throws {
        try await client.request(CartEndpoints.removeItem(productId: productId))
    }

    func updateQuantity(productId: String, quantity: Int) async throws {
        try await client.request(CartEndpoints.updateQuantity(productId: productId, quantity: quantity))
    }
}
