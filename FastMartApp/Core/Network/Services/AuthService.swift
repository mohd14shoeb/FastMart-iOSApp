import Foundation

// MARK: - Auth Service Protocol (for testability)

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> LoginResponse
    func forgotPassword(email: String) async throws -> ForgotPasswordResponse
    func logout() async throws
}

// MARK: - Auth Service Implementation

final class AuthService: AuthServiceProtocol {

    static let shared = AuthService()
    private let client = APIClient.shared

    func login(email: String, password: String) async throws -> LoginResponse {
        let response: LoginResponse = try await client.request(
            AuthEndpoints.login(email: email, password: password)
        )
        // Persist token on success
        UserDefaults.standard.set(response.token, forKey: "auth_token")
        return response
    }

    func forgotPassword(email: String) async throws -> ForgotPasswordResponse {
        try await client.request(AuthEndpoints.forgotPassword(email: email))
    }

    func logout() async throws {
        try? await client.request(AuthEndpoints.logout)
        UserDefaults.standard.removeObject(forKey: "auth_token")
    }
}
