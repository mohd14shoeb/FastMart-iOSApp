import Foundation

// MARK: - Cart Endpoints

enum CartEndpoints {
    case getCart
    case addItem(productId: String, quantity: Int)
    case removeItem(productId: String)
    case updateQuantity(productId: String, quantity: Int)
}

extension CartEndpoints: APIEndpoint {

    var path: String {
        switch self {
        case .getCart:                  return "/cart"
        case .addItem:                  return "/cart/items"
        case .removeItem(let id):       return "/cart/items/\(id)"
        case .updateQuantity(let id, _): return "/cart/items/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getCart:         return .get
        case .addItem:         return .post
        case .removeItem:      return .delete
        case .updateQuantity:  return .patch
        }
    }

}

// MARK: - Cart Response DTOs

struct CartResponse: Decodable {
    let items: [CartItemDTO]
    let total: Double
}

struct CartItemDTO: Decodable {
    let id: String
    let name: String
    let price: Double
    let quantity: Int
}
