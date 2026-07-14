import UIKit

// MARK: - ForgotPassword ViewController (Skeleton)

final class ForgotPasswordViewController: UIViewController {

    private let viewModel: ForgotPasswordViewModel

    private let headerLabel      = UILabel()
    private let emailTextField   = UITextField()
    private let submitButton     = UIButton(type: .system)
    private let messageLabel     = UILabel()

    init(viewModel: ForgotPasswordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Reset Password"
        setupUI()
        setupActions()
        bindViewModel()
    }

    private func setupUI() {
        headerLabel.text = "Forgot Password?"
        headerLabel.font = .systemFont(ofSize: 28, weight: .bold)
        headerLabel.textAlignment = .center

        emailTextField.placeholder = "Email address"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none

        submitButton.setTitle("Send Reset Link", for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        submitButton.backgroundColor = .systemIndigo
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 12
        submitButton.alpha = 0.5

        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        [headerLabel, emailTextField, submitButton, messageLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -50),

            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            emailTextField.widthAnchor.constraint(equalToConstant: 280),
            emailTextField.heightAnchor.constraint(equalToConstant: 48),

            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12),
            messageLabel.widthAnchor.constraint(equalToConstant: 280),

            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            submitButton.widthAnchor.constraint(equalToConstant: 280),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func setupActions() {
        emailTextField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] in
            DispatchQueue.main.async { self?.updateUI() }
        }
    }

    private func updateUI() {
        let vm = viewModel
        submitButton.isEnabled = vm.canSubmit && !vm.isLoading
        submitButton.alpha = vm.canSubmit ? 1.0 : 0.5
        submitButton.setTitle(vm.isLoading ? "Sending..." : "Send Reset Link", for: .normal)

        if let s = vm.successMessage { messageLabel.text = s; messageLabel.textColor = .systemGreen }
        else if let e = vm.errorMessage { messageLabel.text = e; messageLabel.textColor = .systemRed }
        else { messageLabel.text = nil }
    }

    @objc private func emailChanged() { viewModel.update(email: emailTextField.text ?? "") }
    @objc private func submitTapped() { view.endEditing(true); viewModel.submitReset() }
}
