import UIKit

// MARK: - Login ViewController (Skeleton)

final class LoginViewController: UIViewController {

    private let viewModel: LoginViewModel

    // MARK: - UI

    private let titleLabel        = UILabel()
    private let emailTextField    = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton       = UIButton(type: .system)
    private let forgotButton      = UIButton(type: .system)
    private let statusLabel       = UILabel()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - UI Setup

    private func setupUI() {
        titleLabel.text = "🔐 Welcome Back"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center

        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.text = "test@example.com"

        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.text = "password"

        loginButton.setTitle("Sign In", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        loginButton.backgroundColor = .systemIndigo
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 12
        loginButton.alpha = 0.5

        forgotButton.setTitle("Forgot Password?", for: .normal)
        forgotButton.setTitleColor(.systemIndigo, for: .normal)

        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = .systemRed
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0

        [titleLabel, emailTextField, passwordTextField,
         loginButton, forgotButton, statusLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -60),

            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            emailTextField.widthAnchor.constraint(equalToConstant: 280),
            emailTextField.heightAnchor.constraint(equalToConstant: 48),

            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.widthAnchor.constraint(equalToConstant: 280),
            passwordTextField.heightAnchor.constraint(equalToConstant: 48),

            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12),
            statusLabel.widthAnchor.constraint(equalToConstant: 280),

            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            loginButton.widthAnchor.constraint(equalToConstant: 280),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            forgotButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forgotButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
        ])
    }

    // MARK: - Actions

    private func setupActions() {
        emailTextField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        forgotButton.addTarget(self, action: #selector(forgotTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] in
            DispatchQueue.main.async { self?.updateUI() }
        }
    }

    private func updateUI() {
        let vm = viewModel
        loginButton.isEnabled = vm.canSubmit && !vm.isLoading
        loginButton.alpha = vm.canSubmit ? 1.0 : 0.5
        loginButton.setTitle(vm.isLoading ? "Signing in..." : "Sign In", for: .normal)
        statusLabel.text = vm.errorMessage
        statusLabel.isHidden = vm.errorMessage == nil
    }

    @objc private func emailChanged()     { viewModel.update(email: emailTextField.text ?? "") }
    @objc private func passwordChanged()  { viewModel.update(password: passwordTextField.text ?? "") }
    @objc private func loginTapped()      { view.endEditing(true); viewModel.login() }
    @objc private func forgotTapped()     { viewModel.forgotPasswordTapped() }
}
