import Foundation

// MARK: - ForgotPassword ViewModel

final class ForgotPasswordViewModel {

    var email: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var successMessage: String?

    var canSubmit: Bool { !email.isEmpty && email.contains("@") }

    var onBack: (() -> Void)?
    var onResetSent: (() -> Void)?
    var onStateChanged: (() -> Void)?

    func submitReset() {
        guard canSubmit else { return }
        isLoading = true; onStateChanged?()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.isLoading = false
            self.successMessage = "Reset link sent to \(self.email)"
            self.onStateChanged?()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.onResetSent?()
            }
        }
    }

    func goBack() { onBack?() }

    func update(email: String) {
        self.email = email.trimmingCharacters(in: .whitespaces)
        errorMessage = nil
        onStateChanged?()
    }
}
