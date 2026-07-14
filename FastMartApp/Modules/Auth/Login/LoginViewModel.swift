import Foundation

// MARK: - Login ViewModel

final class LoginViewModel {

    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }

    var onLoginSuccess: (() -> Void)?
    var onForgotPassword: (() -> Void)?
    var onStateChanged: (() -> Void)?

    func login() {
        guard canSubmit else { return }
        isLoading = true; errorMessage = nil; onStateChanged?()

        // Simulated auth — accepts any email with "@" and non-empty password
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.isLoading = false
            UserDefaults.standard.set("skeleton_token", forKey: "auth_token")
            self.onLoginSuccess?()
        }
    }

    func forgotPasswordTapped() { onForgotPassword?() }

    func update(email: String)    { self.email = email.trimmingCharacters(in: .whitespaces); errorMessage = nil; onStateChanged?() }
    func update(password: String) { self.password = password; errorMessage = nil; onStateChanged?() }
}
