import Foundation

// MARK: - Login ViewModel

@MainActor
final class LoginViewModel {
    
    // MARK: - Dependencies
    private let authService: AuthServiceProtocol
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    var model = LoginModel()
    
    var canSubmit: Bool {
        !model.email.isEmpty && !model.password.isEmpty && model.email.contains("@")
    }
    
    var onLoginSuccess: (() -> Void)?
    var onForgotPassword: (() -> Void)?
    var onStateChanged: (() -> Void)?
    
    
    func login()  {
        guard canSubmit else { return }
        model.isLoading = true; model.errorMessage = nil; onStateChanged?()
        Task { [weak self] in
            guard let self else { return }
            LoadingIndicator.shared.show(message: "Loading...")
            
            do {
                let loginResponse = try await self.authService.login(
                    email: self.model.email.lowercased(),
                    password: self.model.password
                )
                loginResponse.dump()
                
               self.model.isLoading = false
              //  LoadingIndicator.shared.hide()
                self.onLoginSuccess?()
            } catch {
                LoadingIndicator.shared.hide()
                self.model.isLoading = false
                self.model.errorMessage = error.localizedDescription
                self.onStateChanged?()
            }
        }
    }
    
    func forgotPasswordTapped() {
        onForgotPassword?()
    }
    
    func update(email: String)    {
        self.model.email = email.trimmingCharacters(in: .whitespaces); model.errorMessage = nil; onStateChanged?()
    }
    
    func update(password: String) {
        self.model.password = password; model.errorMessage = nil; onStateChanged?()
    }
}
