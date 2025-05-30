import UIKit

class LoginViewController: UIViewController {
    weak var coordinator: LoginCoordinator?
    private let viewModel = LoginViewModel()
    
    let idTextField = UITextField()
    let passwordTextField = UITextField()
    let loginButton = UIButton(type: .system)
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
        loginButton.backgroundColor = .black
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        signupButton.setTitle("회원가입하기", for: .normal)
        signupButton.setTitleColor(.black, for: .normal)
        signupButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        
        // action
        loginButton.addAction(UIAction {[weak self] _ in
            guard let self = self else { return }
            let email = self.idTextField.text ?? ""
            let password = self.passwordTextField.text ?? ""
            Task {
                do {
                    try await self.viewModel.login(email: email, password: password)
                    self.coordinator?.didFinishLogin()
                } catch {
                    print(error)
                }
            }
            
        }, for: .touchUpInside)
        
        signupButton.addAction(UIAction {[weak self] _ in
            self?.coordinator?.showRegister()
        }, for: .touchUpInside)
        
        view.addSubview(loginButton)
        view.addSubview(signupButton)
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

#Preview {
    LoginViewController()
}
