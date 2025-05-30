import Foundation
import Combine

class RegisterViewModel {
    private let dataManager = SupabaseDataManager.shared
    
    // MARK: - Input Properties (@Published)
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var otpCode: String = ""

    // MARK: - Output Validation States (@Published private(set))
    @Published private(set) var isNameValid: Bool = false
    @Published private(set) var isEmailValid: Bool = false
    @Published private(set) var isPasswordValid: Bool = false
    @Published private(set) var isPasswordConfirmed: Bool = false
    // isFormValid는 OTP 입력 전 사용자 입력 필드(이름, 비밀번호, 비밀번호 확인)의 유효성
    @Published private(set) var isFormValid: Bool = false

    // MARK: - Output Error Messages (@Published private(set))
    // 이 프로퍼티들은 private(set)으로 클래스 내부에서만 set 가능해야 하며, var로 선언되어야 합니다.
    @Published private(set) var nameErrorMessage: String = ""
    @Published private(set) var emailErrorMessage: String = ""
    @Published private(set) var passwordErrorMessage: String = ""
    @Published private(set) var confirmPasswordErrorMessage: String = ""

    // MARK: - OTP Flow State (@Published private(set))
    @Published private(set) var isOTPSent: Bool = false
    @Published var otpVerificationError: String? // VC에서 직접 관찰 또는 토스트로 사용

    // MARK: - Loading State (@Published private(set))
    @Published private(set) var isLoading: Bool = false
    var isLoadingPublisher: AnyPublisher<Bool, Never> { $isLoading.eraseToAnyPublisher() }

    // MARK: - Registration Result
    private let registrationResultSubject = PassthroughSubject<Bool, Never>()
    var registrationResultPublisher: AnyPublisher<Bool, Never> { registrationResultSubject.eraseToAnyPublisher() }

    // 이메일 중복과 같은 특정 알림을 위한 Subject
    let infoMessageSubject = PassthroughSubject<String, Never>()
    var infoMessagePublisher: AnyPublisher<String, Never> { infoMessageSubject.eraseToAnyPublisher() }

    private var cancellables = Set<AnyCancellable>()

    init() {
        bindValidations()
        bindErrorMessages()
    }

    private func bindValidations() {
        $name
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .receive(on: RunLoop.main)
            .assign(to: \.isNameValid, on: self)
            .store(in: &cancellables)

        $email
            .map { NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with: $0) }
            .receive(on: RunLoop.main)
            .assign(to: \.isEmailValid, on: self)
            .store(in: &cancellables)

        $password
            .map { $0.count >= 6 }
            .receive(on: RunLoop.main)
            .assign(to: \.isPasswordValid, on: self)
            .store(in: &cancellables)

        Publishers.CombineLatest($password, $confirmPassword)
            .map { pass, confirmPass in !confirmPass.isEmpty && pass == confirmPass }
            .receive(on: RunLoop.main)
            .assign(to: \.isPasswordConfirmed, on: self)
            .store(in: &cancellables)

        // isFormValid는 사용자가 OTP 입력 전에 채워야 할 모든 필드(이름, 비밀번호, 비밀번호 확인)의 유효성을 나타냄.
        Publishers.CombineLatest3($isNameValid, $isPasswordValid, $isPasswordConfirmed)
            .map { name, pass, confirmPass in name && pass && confirmPass }
            .receive(on: RunLoop.main)
            .assign(to: \.isFormValid, on: self)
            .store(in: &cancellables)
    }

    private func bindErrorMessages() {
        let debounceInterval: RunLoop.SchedulerTimeType.Stride = .milliseconds(100)

        $isNameValid.combineLatest($name.map { $0.isEmpty })
            .debounce(for: debounceInterval, scheduler: RunLoop.main)
            .dropFirst()
            .map { isValid, isEmpty in isEmpty ? "이름을 입력해주세요." : (isValid ? "" : "이름을 확인해주세요.") }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: \.nameErrorMessage, on: self) // 오류 발생 가능 지점
            .store(in: &cancellables)

        $isEmailValid.combineLatest($email.map { $0.isEmpty })
            .debounce(for: debounceInterval, scheduler: RunLoop.main)
            .dropFirst()
            .map { isValid, isEmpty in isEmpty ? "이메일을 입력해주세요." : (isValid ? "" : "올바른 이메일 형식이 아닙니다.") }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: \.emailErrorMessage, on: self) // 오류 발생 가능 지점
            .store(in: &cancellables)

        $isPasswordValid.combineLatest($password.map { $0.isEmpty })
            .debounce(for: debounceInterval, scheduler: RunLoop.main)
            .dropFirst()
            .map { isValid, isEmpty in isEmpty ? "비밀번호를 입력해주세요." : (isValid ? "" : "비밀번호는 6자 이상이어야 합니다.") }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: \.passwordErrorMessage, on: self) // 오류 발생 가능 지점
            .store(in: &cancellables)

        Publishers.CombineLatest3($isPasswordConfirmed, $password, $confirmPassword)
            .debounce(for: debounceInterval, scheduler: RunLoop.main)
            .dropFirst()
            .map { isConfirmed, pass, confirmP -> String in
                if pass.isEmpty && confirmP.isEmpty { return "" }
                if !pass.isEmpty && pass.count >= 6 && confirmP.isEmpty { return "비밀번호를 다시 입력해주세요." }
                if !confirmP.isEmpty && !isConfirmed { return "비밀번호가 일치하지 않습니다." }
                return ""
            }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: \.confirmPasswordErrorMessage, on: self) // 오류 발생 가능 지점
            .store(in: &cancellables)
    }

    /// "인증번호 받기" 버튼에 연결될 함수
    func requestOtp() {
        guard isFormValid, isEmailValid else {
            isOTPSent = false
            // 필요하다면 infoMessageSubject.send("모든 정보를 올바르게 입력해주세요.")
            return
        }

        isLoading = true
        otpVerificationError = nil
        isOTPSent = false

        Task {
            do {
                let emailExists = try await dataManager.checkEmailExists(self.email)

                if emailExists {
                    await MainActor.run {
                        self.isLoading = false
                        self.infoMessageSubject.send("이미 가입된 이메일입니다.")
                        self.isOTPSent = false
                    }
                    return
                }

                try await dataManager.sendOtpToEmail(self.email)
                print("send otp")
                await MainActor.run {
                    self.isLoading = false
                    self.isOTPSent = true
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.otpVerificationError = error.localizedDescription
                    self.isOTPSent = false
                }
            }
        }
    }

    /// "인증하고 가입 완료" 버튼에 연결될 함수
    func verifyOtpAndCompleteRegistration() {
        guard isOTPSent else {
            otpVerificationError = "먼저 인증번호를 요청해주세요."
            registrationResultSubject.send(false)
            return
        }
        guard !otpCode.isEmpty, otpCode.count == 6 else {
            otpVerificationError = "올바른 6자리 인증번호를 입력해주세요."
            registrationResultSubject.send(false)
            return
        }
        guard isFormValid else {
            otpVerificationError = "이름, 비밀번호 등 모든 정보를 올바르게 입력해주세요."
            registrationResultSubject.send(false)
            return
        }

        isLoading = true
        otpVerificationError = nil

        Task {
            do {
                try await dataManager.checkOtpForEmail(self.email, otp: self.otpCode)

                guard let authUser = dataManager.getCurrentAuthenticatedUser() else {
                    throw VerificationError(errorDescription: "OTP 검증 후 사용자 세션을 확인할 수 없습니다.")
                }

                try await updatePasswordAfterOtpVerification()
                
                let data = Users(
                    userId: authUser.userId,
                    name: self.name.isEmpty ? authUser.name : self.name,
                    age: nil,
                    nickname: nil,
                    email: authUser.email,
                    profileImageURL: nil,
                    createdAt: Date()
                )
                
                let _ = await dataManager.insertData(data)

                await MainActor.run {
                    self.isLoading = false
                    self.registrationResultSubject.send(true)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.otpVerificationError = error.localizedDescription
                    self.registrationResultSubject.send(false)
                }
            }
        }
    }

    /// OTP 검증 후 비밀번호만 업데이트하는 함수
    private func updatePasswordAfterOtpVerification() async throws {
        if isPasswordValid && isPasswordConfirmed && !password.isEmpty {
            let passwordUpdate = UserUpdateField.password(self.password) // UserUpdateField가 정의되어 있다고 가정
            try await SupabaseDataManager.shared.updateUserField(passwordUpdate)
        } else if !password.isEmpty {
            throw PasswordValidationError(errorDescription: "설정하려는 비밀번호가 유효하지 않습니다.")
        }
    }

    // MARK: - Custom Error Types
    struct VerificationError: LocalizedError { var errorDescription: String? }
    struct PasswordValidationError: LocalizedError { var errorDescription: String? }
}
