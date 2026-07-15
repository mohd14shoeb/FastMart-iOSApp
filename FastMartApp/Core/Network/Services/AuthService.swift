import Foundation

// MARK: - Auth Service Protocol (for testability)

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> LoginResponse
    func forgotPassword(email: String) async throws
    func logout() async throws
}

// MARK: - Auth Service Implementation

final class AuthService: AuthServiceProtocol {
    
    static let shared = AuthService()
    private let client = APIClient.shared
    private let session = SessionStore.shared
    
    func login(email: String, password: String) async throws -> LoginResponse {
        
        do {
            let response: LoginResponse = try await client.request(
                AuthEndpoints.login(email: email, password: password)
            )
            // ── Persist token (Keychain) + user profile (UserDefaults) ──
            session.authToken = response.accessToken
            session.saveUser(response)
            //  logSuccess("Login successful — token saved")
            return response
            
        } catch {
            // Error already carries backend's message via APIError.errorDescription
            logError("Login failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func forgotPassword(email: String) async throws {
        do {
            try await client.request(
                AuthEndpoints.forgotPassword(email: email)
            )
            logSuccess("Password reset link sent to \(email)")
        } catch {
            logError("Forgot password failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func logout() async throws {
        do {
            try await client.request(AuthEndpoints.logout)
            logInfo("Logout successful")
        } catch {
            logWarning("Logout API call failed: \(error.localizedDescription)")
        }
        session.clearAll()
    }
}
