import UIKit

// MARK: - UIView + Shake Animation

extension UIViewController {
    func shake(view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-8, 8, -6, 6, -3, 3, 0]
        view.layer.add(animation, forKey: "shake")
    }
    
        func addCustomBackButton(
            title: String = "Back",
            action: @escaping () -> Void
        ) {
            navigationItem.hidesBackButton = true

            let button = UIButton(type: .system)

            var configuration = UIButton.Configuration.plain()
            configuration.title = title
            configuration.image = UIImage(
                systemName: "chevron.backward"
            )
            configuration.imagePadding = 4
            configuration.contentInsets = .zero

            button.configuration = configuration

            button.addAction(
                UIAction { _ in
                    action()
                },
                for: .touchUpInside
            )

            navigationItem.leftBarButtonItem =
                UIBarButtonItem(customView: button)
        }
}

// MARK: - UITextField + Password Toggle

extension UITextField {
    func enablePasswordToggle() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.tintColor = .secondaryLabel
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        rightView = button
        rightViewMode = .always
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        isSecureTextEntry.toggle()
        let icon = isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        sender.setImage(UIImage(systemName: icon), for: .normal)
    }
}

// MARK: - UIViewController + Keyboard Handling

extension UIViewController {

    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
        else { return }

        let inset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        scrollView.contentInset = inset
        scrollView.scrollIndicatorInsets = inset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
        else { return }
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}
