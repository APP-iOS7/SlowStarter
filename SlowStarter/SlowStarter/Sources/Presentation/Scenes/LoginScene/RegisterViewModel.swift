import Foundation
import Combine

class RegisterViewModel {
    private let dataManager = SupabaseDataManager.shared
    
    //input
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var otpCode: String = ""

    // validation
    @Published private(set) var isNameValid: Bool = false
    @Published private(set) var isEmailValid: Bool = false
    @Published private(set) var isPasswordValid: Bool = false
    @Published private(set) var isPasswordConfirmed: Bool = false
    // 전체 유효성 검사하는 프로퍼티
    @Published private(set) var isFormValid: Bool = false

    // 형식에 맞지 않을 시 표시할 메세지
    @Published private(set) var nameErrorMessage: String = ""
    @Published private(set) var emailErrorMessage: String = ""
    @Published private(set) var passwordErrorMessage: String = ""
    @Published private(set) var confirmPasswordErrorMessage: String = ""

    // OTP 상태 관련 프로퍼티
    @Published private(set) var isOTPSent: Bool = false
    // 토스트로 표시할 OTP에러 메세지
    @Published var otpVerificationError: String?

    // 로딩 서클 상태 프로퍼티
    @Published private(set) var isLoading: Bool = false
    var isLoadingPublisher: AnyPublisher<Bool, Never> { $isLoading.eraseToAnyPublisher() }

    // 결과 전달 컴바인
    private let registrationResultSubject = PassthroughSubject<Bool, Never>()
    var registrationResultPublisher: AnyPublisher<Bool, Never> { registrationResultSubject.eraseToAnyPublisher() }

    // 등록 시 현 상태를 나타낼 컴바인
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
            .map { NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with: $0) }
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
            .assign(to: \.nameErrorMessage, on: self)
            .store(in: &cancellables)

        $isEmailValid.combineLatest($email.map { $0.isEmpty })
            .debounce(for: debounceInterval, scheduler: RunLoop.main)
            .dropFirst()
            .map { isValid, isEmpty in isEmpty ? "이메일을 입력해주세요." : (isValid ? "" : "올바른 이메일 형식이 아닙니다.") }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: \.emailErrorMessage, on: self)
            .store(in: &cancellables)

        $isPasswordValid.combineLatest($password.map { $0.isEmpty })
            .debounce(for: debounceInterval, scheduler: RunLoop.main)
            .dropFirst()
            .map { isValid, isEmpty in isEmpty ? "비밀번호를 입력해주세요." : (isValid ? "" : "비밀번호는 6자 이상이어야 합니다.") }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: \.passwordErrorMessage, on: self)
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
            .assign(to: \.confirmPasswordErrorMessage, on: self)
            .store(in: &cancellables)
    }

    /// "인증번호 받기" 버튼용 함수
    func requestOtp() {
        guard isFormValid, isEmailValid else {
            isOTPSent = false
            //infoMessageSubject.send("모든 정보를 올바르게 입력해주세요.")
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

    /// "인증하고 가입 완료" 버튼용 함수
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
                    throw LoginManagerError.verificationError(error: "OTP 검증 후 사용자 세션을 확인할 수 없습니다.")
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
                
                // 데이터 베이스에 정보 저장
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
            let passwordUpdate = UserUpdateField.password(self.password)
            try await SupabaseDataManager.shared.updateUserField(passwordUpdate)
        } else if !password.isEmpty {
            throw LoginManagerError.passwordValidationError(error: "설정하려는 비밀번호가 유효하지 않습니다.")
        }
    }
}
