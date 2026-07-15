import Foundation

// MARK: - Login Model

struct LoginModel {
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
}
