import UIKit
import Combine

class RegisterViewController: UIViewController {
    weak var coordinator: RegisterCoordinator?
    private let viewModel = RegisterViewModel()
    private var cancellables = Set<AnyCancellable>()

// MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    // 기본 정보 필드
    private let nameTextField = UITextField()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()

    // 기본 정보 에러 레이블
    private let nameErrorLabel = UILabel()
    private let emailErrorLabel = UILabel()
    private let passwordErrorLabel = UILabel()
    private let confirmPasswordErrorLabel = UILabel()

    // OTP 관련 UI
    private let otpLabel = UILabel()
    private let otpTextField = UITextField()
    private let otpErrorLabel = UILabel()

    // 버튼
    private let requestOtpButton = UIButton(type: .system)
    private let registerFinalButton = UIButton(type: .system)

    // 로딩 인디케이터
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "회원가입"

        setupScrollView()
        setupStackView()
        setupFields()
        setupButtons()
        setupActivityIndicator()
        
        bindViewModel()
        bindCombine()
        
        setupKeyboardObserver()
        setupGesture()
        
        updateUIState(isOTPSent: false, isEmailValidForOtp: false, isBaseFormValid: false)
    }

    // MARK: - Setup UI
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // textField
    private func setupFields() {
        let elementsLabelText: [String] = ["이름", "이메일", "비밀번호 설정", "비밀번호 확인"]
        let elementsTextFields: [UITextField] = [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField]
        let elementsPlaceHolder: [String] = ["이름을 입력해주세요.", "이메일을 입력해주세요.", "비밀번호를 6자리 이상 입력해주세요.", "비밀번호를 다시 입력해주세요."]
        let elementsErrorLabels: [UILabel] = [nameErrorLabel, emailErrorLabel, passwordErrorLabel, confirmPasswordErrorLabel]
        
        for index in elementsLabelText.indices {
            elementsTextFields[index].delegate = self
            let currentLabelText = elementsLabelText[index]
            let currentTextField = elementsTextFields[index]
            let currentPlaceHolder = elementsPlaceHolder[index]
            let currentErrorLabel = elementsErrorLabels[index]
            
            let currentLabel = createLabel(text: currentLabelText)
            
            if currentTextField == emailTextField {
                configureTextField(currentTextField, placeholder: currentPlaceHolder, keyboardType: .emailAddress)
            } else if currentTextField == passwordTextField {
                configureTextField(currentTextField, placeholder: currentPlaceHolder, isSecure: true, textContentType: .oneTimeCode)
            } else if currentTextField == confirmPasswordTextField {
                configureTextField(currentTextField, placeholder: currentPlaceHolder, isSecure: true, returnKeyType: .done, textContentType: .oneTimeCode)
            } else {
                configureTextField(currentTextField, placeholder: currentPlaceHolder)
            }
            
            configureErrorLabel(currentErrorLabel)
            
            stackView.addArrangedSubview(currentLabel)
            stackView.addArrangedSubview(currentTextField)
            stackView.addArrangedSubview(currentErrorLabel)
            
            stackView.setCustomSpacing(8, after: currentLabel)
            stackView.setCustomSpacing(4, after: currentTextField)
            stackView.setCustomSpacing(16, after: currentErrorLabel)

        }
        
        otpLabel.text = "인증번호"
        otpLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        otpLabel.textColor = .label
        
        configureTextField(otpTextField, placeholder: "입력하신 메일에 받은 6자리를 입력해주세요.", keyboardType: .numberPad, returnKeyType: .done, textContentType: .oneTimeCode)

        configureErrorLabel(otpErrorLabel)
        
        stackView.addArrangedSubview(requestOtpButton)
        stackView.addArrangedSubview(otpLabel)
        stackView.addArrangedSubview(otpTextField)
        stackView.addArrangedSubview(otpErrorLabel)
        
        stackView.setCustomSpacing(24, after: requestOtpButton)
        stackView.setCustomSpacing(8, after: otpLabel)
        stackView.setCustomSpacing(4, after: otpTextField)
        stackView.setCustomSpacing(16, after: otpErrorLabel)
        
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }

    private func configureTextField(_ textField: UITextField, placeholder: String, isSecure: Bool = false, keyboardType: UIKeyboardType = .default, returnKeyType: UIReturnKeyType = .next, textContentType: UITextContentType? = nil) {
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.keyboardType = keyboardType
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.inputAccessoryView = makeToolbar()
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.returnKeyType = returnKeyType
        textField.delegate = self
        if let textContentType {
            textField.textContentType = textContentType
        }
    }

    private func configureErrorLabel(_ label: UILabel) {
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 16).isActive = true
    }
    
    // Button
    private func setupButtons() {
        configureStyledButton(requestOtpButton, title: "인증번호 받기", backgroundColor: UIColor(hex: "#FFA500") ?? .black)
        requestOtpButton.addAction(UIAction { [weak self] _ in self?.viewModel.requestOtp() }, for: .touchUpInside)

        configureStyledButton(registerFinalButton, title: "인증하고 가입 완료", backgroundColor: UIColor(hex: "#FFA500") ?? .black)
        registerFinalButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.otpCode = self?.otpTextField.text ?? ""
            self?.viewModel.verifyOtpAndCompleteRegistration()
        }, for: .touchUpInside)
        stackView.addArrangedSubview(registerFinalButton)
    }
    
    private func configureStyledButton(_ button: UIButton, title: String, backgroundColor: UIColor, titleColor: UIColor = .white) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColor, for: .normal)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.alpha = 0.5
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    // Indicator
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemGray
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - UI State Update
    private func updateUIState(isOTPSent: Bool, isEmailValidForOtp: Bool, isBaseFormValid: Bool) {
        nameTextField.isEnabled = !isOTPSent
        emailTextField.isEnabled = !isOTPSent
        passwordTextField.isEnabled = !isOTPSent
        confirmPasswordTextField.isEnabled = !isOTPSent

        let canRequestOtp = isBaseFormValid && isEmailValidForOtp && !isOTPSent && !activityIndicator.isAnimating
        requestOtpButton.isEnabled = canRequestOtp
        requestOtpButton.alpha = canRequestOtp ? 1.0 : 0.5
        requestOtpButton.isHidden = isOTPSent

        otpLabel.isHidden = !isOTPSent
        otpTextField.isHidden = !isOTPSent
        otpErrorLabel.isHidden = !isOTPSent

        registerFinalButton.isHidden = !isOTPSent

        if isOTPSent && !otpTextField.isHidden {
            otpTextField.becomeFirstResponder()
        }
    }

    private func showLoading(_ isShow: Bool) {
        if isShow {
            activityIndicator.startAnimating()
            requestOtpButton.isEnabled = false
            registerFinalButton.isEnabled = false
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
            updateUIState(
                isOTPSent: viewModel.isOTPSent,
                isEmailValidForOtp: viewModel.isEmailValid,
                isBaseFormValid: viewModel.isFormValid
            )
            
             let otpCodeValid = !(otpTextField.text?.isEmpty ?? true) && (otpTextField.text?.count == 6)
             let canRegisterFinal = viewModel.isOTPSent && viewModel.isFormValid && otpCodeValid && !activityIndicator.isAnimating
             registerFinalButton.isEnabled = canRegisterFinal
             registerFinalButton.alpha = canRegisterFinal ? 1.0 : 0.5
        }
    }
}

// MARK: - Combine
extension RegisterViewController {
    private func bindViewModel() {
        // textField bind
        nameTextField.textPublisher
            .assign(to: \.name, on: viewModel)
            .store(in: &cancellables)
        
        emailTextField.textPublisher
            .assign(to: \.email, on: viewModel)
            .store(in: &cancellables)
        
        passwordTextField.textPublisher
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)
        
        confirmPasswordTextField.textPublisher
            .assign(to: \.confirmPassword, on: viewModel)
            .store(in: &cancellables)
        
        // viewModel bind
        viewModel.$nameErrorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] text in self?.nameErrorLabel.text = text }
            .store(in: &cancellables)
        
        viewModel.$emailErrorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] text in self?.emailErrorLabel.text = text }
            .store(in: &cancellables)
        
        viewModel.$passwordErrorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] text in self?.passwordErrorLabel.text = text }
            .store(in: &cancellables)
        
        viewModel.$confirmPasswordErrorMessage.receive(on: RunLoop.main)
            .sink { [weak self] text in self?.confirmPasswordErrorLabel.text = text }
            .store(in: &cancellables)
        
        viewModel.$otpVerificationError
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.otpErrorLabel.text = text
            }
            .store(in: &cancellables)

        // 회원가입 실패
        viewModel.infoMessagePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                self?.showToast(message: message, backgroundColor: .systemOrange.withAlphaComponent(0.85))
            }
            .store(in: &cancellables)
    }
    
    private func bindCombine() {
        Publishers.CombineLatest3(viewModel.$isEmailValid, viewModel.$isFormValid, viewModel.$isOTPSent)
            .receive(on: RunLoop.main)
            .sink { [weak self] isEmailValid, isBaseFormValid, isOtpSent in
                guard let self = self else { return }
                self.updateUIState(
                    isOTPSent: isOtpSent,
                    isEmailValidForOtp: isEmailValid,
                    isBaseFormValid: isBaseFormValid
                )
            }
            .store(in: &cancellables)

        Publishers.CombineLatest3(viewModel.$isFormValid, otpTextField.textPublisher, viewModel.$isOTPSent)
            .map { isBaseFormValid, otpText, isOtpSent -> Bool in
                let otpCodeValid = !otpText.isEmpty && otpText.count == 6
                return isOtpSent && isBaseFormValid && otpCodeValid
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] isValidForFinalRegister in
                guard let self = self, !self.activityIndicator.isAnimating else { return }
                if self.viewModel.isOTPSent {
                    self.registerFinalButton.isEnabled = isValidForFinalRegister
                    self.registerFinalButton.alpha = isValidForFinalRegister ? 1.0 : 0.5
                } else {
                    self.registerFinalButton.isEnabled = false
                    self.registerFinalButton.alpha = 0.5
                }
            }
            .store(in: &cancellables)

        viewModel.$isOTPSent
            .receive(on: RunLoop.main)
            .sink { [weak self] sent in
                guard let self = self else { return }
                self.updateUIState(
                    isOTPSent: sent,
                    isEmailValidForOtp: self.viewModel.isEmailValid,
                    isBaseFormValid: self.viewModel.isFormValid
                )
                if sent {
                    self.showToast(message: "인증번호가 이메일로 전송되었습니다.", backgroundColor: UIColor.systemBlue.withAlphaComponent(0.8))
                }
            }
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                self?.showLoading(isLoading)
            }
            .store(in: &cancellables)

        viewModel.registrationResultPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] success in
                guard let self = self else { return }
                if success {
                    self.navigationController?.popViewController(animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.showToast(message: "회원가입 성공!", backgroundColor: UIColor.systemGreen.withAlphaComponent(0.8))
                    }
                } else {
                    let errorMessage = self.viewModel.otpVerificationError ?? "가입 처리 중 오류가 발생했습니다."
                    self.showToast(message: errorMessage, backgroundColor: UIColor.systemRed.withAlphaComponent(0.8))
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Toast Message
extension RegisterViewController {
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

// MARK: - Keyboard & Gesture
extension RegisterViewController {
    func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    // KeyBoard ToolBar
    private func makeToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, done]
        return toolbar
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupKeyboardObserver() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .receive(on: RunLoop.main)
            .sink { [weak self] keyboardFrame in
                guard let self = self else { return }
                let bottomInset = keyboardFrame.height - (self.view.safeAreaInsets.bottom) + 20
                self.scrollView.contentInset.bottom = bottomInset
                self.scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.scrollView.contentInset.bottom = 0
                self?.scrollView.verticalScrollIndicatorInsets.bottom = 0
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField: emailTextField.becomeFirstResponder()
        case emailTextField: passwordTextField.becomeFirstResponder()
        case passwordTextField: confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            if viewModel.isOTPSent {
                otpTextField.becomeFirstResponder()
            } else {
                view.endEditing(true)
            }
        case otpTextField:
            if viewModel.isOTPSent && viewModel.isFormValid && !(otpTextField.text?.isEmpty ?? true) && (otpTextField.text?.count == 6) {
                viewModel.otpCode = otpTextField.text ?? ""
                viewModel.verifyOtpAndCompleteRegistration()
            } else {
                textField.resignFirstResponder()
            }
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - UITextField Extension
extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextField)?.text }
            .eraseToAnyPublisher()
    }
}
