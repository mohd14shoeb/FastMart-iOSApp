import Foundation

// MARK: - Auth Endpoints

enum AuthEndpoints {
    case login(email: String, password: String)
    case forgotPassword(email: String)
    case refreshToken
    case logout
}

extension AuthEndpoints: APIEndpoint {

    var path: String {
        switch self {
        case .login:           return "/auth/login"
        case .forgotPassword:  return "/auth/forgot-password"
        case .refreshToken:    return "/auth/refresh"
        case .logout:          return "/auth/logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .forgotPassword, .refreshToken, .logout:
            return .post
        }
    }

    var body: Data? {
        switch self {
        case .login(let email, let password):
            return try? JSONEncoder().encode(LoginRequest(email: email, password: password))
        case .forgotPassword(let email):
            return try? JSONEncoder().encode(ForgotPasswordRequest(email: email))
        case .refreshToken, .logout:
            return nil
        }
    }

    // ── Encodable request bodies ──

    private struct LoginRequest: Encodable {
        let email: String
        let password: String
    }

    private struct ForgotPasswordRequest: Encodable {
        let email: String
    }
}

// MARK: - Auth Response DTOs

struct LoginResponse: Decodable {
    let token: String
    let userId: String
    let name: String
}

struct ForgotPasswordResponse: Decodable {
    let message: String
}
