import UIKit

class LoginViewController: UIViewController {
    weak var coordinator: LoginCoordinator?
    private let viewModel = LoginViewModel()
    
    var completion: (() -> Void)?
    
    let idTextField = UITextField()
    let passwordTextField = UITextField()
    let loginButton = UIButton(type: .system)
    private let loginSpinner = UIActivityIndicatorView(style: .medium)
    let signupButton = UIButton(type: .system)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupGesture()
    }
    
    // MARK: UI
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "로그인"
        setupTextField()
        setupButton()
        setupLayout()
    }
    
    func setupTextField() {
        idTextField.placeholder = "아이디(이메일)"
        idTextField.borderStyle = .roundedRect
        idTextField.backgroundColor = .white
        idTextField.autocapitalizationType = .none
        idTextField.keyboardType = .emailAddress
        idTextField.spellCheckingType = .no
        idTextField.returnKeyType = .next
        idTextField.inputAccessoryView = textFieldToolBar()
        idTextField.delegate = self
        idTextField.translatesAutoresizingMaskIntoConstraints = false
        
        passwordTextField.placeholder = "비밀번호"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.backgroundColor = .white
        passwordTextField.autocapitalizationType = .none
        passwordTextField.returnKeyType = .done
        passwordTextField.inputAccessoryView = textFieldToolBar()
        passwordTextField.delegate = self
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(idTextField)
        view.addSubview(passwordTextField)
    }
    
    func setupButton() {
        // Elements
        loginButton.setTitle("로그인하기", for: .normal)
        loginButton.backgroundColor = .brown
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        loginSpinner.hidesWhenStopped = true
        loginSpinner.translatesAutoresizingMaskIntoConstraints = false
        
        signupButton.setTitle("회원가입하기", for: .normal)
        signupButton.setTitleColor(.black, for: .normal)
        signupButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        
        // action
        loginButton.addAction(UIAction {[weak self] _ in
            guard let self = self else { return }
            
            let email = self.idTextField.text ?? ""
            let password = self.passwordTextField.text ?? ""
            
            self.setLoginButtonLoading(true)
            
            Task {
                do {
                    try await self.viewModel.login(email: email, password: password)
                    self.setLoginButtonLoading(false)
                    if self.completion == nil {
                        self.coordinator?.didFinishLogin()
                    } else {
                        self.completion?()
                    }
                } catch {
                    self.setLoginButtonLoading(false)
                    self.showToast(message: "로그인 정보가 잘못되었습니다.")
                }
            }
            
        }, for: .touchUpInside)
        
        signupButton.addAction(UIAction {[weak self] _ in
            self?.coordinator?.showRegister()
        }, for: .touchUpInside)
        
        view.addSubview(loginButton)
        loginButton.addSubview(loginSpinner)
        view.addSubview(signupButton)
    }
    
    private func setLoginButtonLoading(_ isLoding: Bool) {
        loginButton.setTitle(isLoding ? "" : "로그인하기", for: .normal)
        isLoding ? loginSpinner.startAnimating() : loginSpinner.stopAnimating()
        loginButton.isEnabled = !isLoding
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            idTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            idTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            idTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            idTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: idTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: idTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: idTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: idTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: idTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            
            loginSpinner.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            loginSpinner.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            
            signupButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            signupButton.leadingAnchor.constraint(equalTo: idTextField.leadingAnchor)
        ])
    }
    
    func textFieldToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", image: nil, primaryAction: UIAction {[weak self] _ in
            self?.view.endEditing(true)
        }, menu: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        return toolbar
    }
    
    // MARK: Gesture
    func setupGesture() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: Delegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == idTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: Toast
extension LoginViewController {
    private func showToast(message: String, duration: TimeInterval = 2.5, backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.75), textColor: UIColor = .white, completion: (() -> Void)? = nil) {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first else {
            print("Key window not found for toast.")
            completion?()
            return
        }
        
        keyWindow.subviews.filter { $0.tag == 9999 }.forEach { $0.removeFromSuperview() }
        
        let toastView = UIView()
        toastView.tag = 9999
        toastView.backgroundColor = backgroundColor
        toastView.layer.cornerRadius = 10
        toastView.clipsToBounds = true
        toastView.alpha = 0.0
        
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = textColor
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        toastLabel.numberOfLines = 0
        
        toastView.addSubview(toastLabel)
        keyWindow.addSubview(toastView)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastView.translatesAutoresizingMaskIntoConstraints = false
        
        let initialBottomConstant: CGFloat = 80
        let finalBottomConstant: CGFloat = -60
        let bottomConstraint = toastView.bottomAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.bottomAnchor, constant: initialBottomConstant)
        
        NSLayoutConstraint.activate([
            toastLabel.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 16),
            toastLabel.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -16),
            toastLabel.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 10),
            toastLabel.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -10),
            
            toastView.leadingAnchor.constraint(greaterThanOrEqualTo: keyWindow.leadingAnchor, constant: 30),
            toastView.trailingAnchor.constraint(lessThanOrEqualTo: keyWindow.trailingAnchor, constant: -30),
            toastView.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor),
            bottomConstraint
        ])
        
        keyWindow.layoutIfNeeded()
        
        toastView.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                toastView.alpha = 1.0
                toastView.transform = .identity
                bottomConstraint.constant = finalBottomConstant
                keyWindow.layoutIfNeeded()
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.5,
                    delay: duration - 0.5,
                    options: .curveEaseIn,
                    animations: {
                        toastView.alpha = 0.0
                        toastView.transform = CGAffineTransform(translationX: 0, y: 50)
                    },
                    completion: { _ in
                        toastView.removeFromSuperview()
                        completion?()
                    }
                )
            }
        )
        
    }
}

#Preview {
    LoginViewController()
}
