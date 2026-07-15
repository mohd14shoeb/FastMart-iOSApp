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
        case .login:           return "/users/login"
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

    /// Login uses form-urlencoded (OAuth2 standard), everything else uses JSON.
    var headers: [String: String]? {
        switch self {
        case .login:
            return ["Content-Type": "application/x-www-form-urlencoded"]
        default:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case .login(let email, let password):
            // Form-encoded: username=user%40gmail.com&password=secret
            let encoded = "username=\(urlEncode(email))&password=\(urlEncode(password))"
            return encoded.data(using: .utf8)

        case .forgotPassword(let email):
            return try? JSONEncoder().encode(ForgotPasswordRequest(email: email))

        case .refreshToken, .logout:
            return nil
        }
    }

    // MARK: - Helpers

    private func urlEncode(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            ?? string
    }

    // MARK: - Request body structs

    private struct ForgotPasswordRequest: Encodable {
        let email: String
    }
}

// MARK: - Auth Response DTOs

struct LoginResponse: Decodable {
   
    let accessToken: String
    let tokenType: String
    let userName: String
    let userId: Int
  
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType   = "token_type"
        case userName = "name"
        case userId   = "user_id"
    }
    
    func dump() {
        debugPrint("──────────────────────────────────────────────────")
        debugPrint("✅ LOGIN RESPONSE Model")
        debugPrint("──────────────────────────────────────────────────")
        debugPrint("User ID   : \(userId)")
        debugPrint("Name      : \(userName)")
        debugPrint("Token Type: \(tokenType)")
        debugPrint("Token     : \(accessToken.prefix(30))...<redacted>")
        debugPrint("──────────────────────────────────────────────────")
    }
}

struct ForgotPasswordResponse: Decodable {
    let message: String
}
