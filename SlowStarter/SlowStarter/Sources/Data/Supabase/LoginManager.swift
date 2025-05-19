//
//  LoginManager.swift
//  SlowStarter
//
//  Created by 고요한 on 5/19/25.
//

import Foundation
import Supabase

class LoginManager: LoginManagerProtocol {
    private var client: SupabaseClient
    private let auth: AuthClient
    
    init(client: SupabaseClient) {
        self.client = client
        self.auth = client.auth
    }
    
    // MARK: - 회원가입
    
    /// 이메일과 비밀번호로 회원가입을 수행합니다.
    /// - Parameters:
    ///   - email: 사용자 이메일
    ///   - password: 사용자 비밀번호
    func signUp(email: String, password: String) async throws {
        do {
            try await auth.signUp(email: email, password: password)
        } catch {
            throw mapAuthError(error)
        }
    }
    
    
    // MARK: - 로그인
    
    /// 이메일과 비밀번호로 로그인을 수행합니다.
    /// - Parameters:
    ///   - email: 사용자 이메일
    ///   - password: 사용자 비밀번호
    func login(email: String, password: String) async throws {
        do {
            let session = try await auth.signIn(email: email, password: password)
        } catch {
            throw mapAuthError(error)
        }
    }
    
    // MARK: - 로그아웃
    
    /// 현재 로그인된 사용자를 로그아웃합니다.
    func logout() async throws {
        do {
            try await auth.signOut()
        } catch {
            throw mapAuthError(error)
        }
    }
    
    // MARK: - 사용자 삭제
    //차후
    
    // MARK: - 현재 사용자 정보 조회
    
    /// 현재 세션의 사용자 정보를 서버에서 가져옵니다.
    /// - Returns: 사용자 정보 (`User?`)
    func getCurrentUserInSession() async throws -> User? {
        do {
            return try await auth.user()
        } catch {
            throw mapAuthError(error)
        }
    }
    
    /// 현재 클라이언트에 저장된 사용자 정보를 반환합니다.
    /// - Returns: 사용자 정보 (`User?`)
    func getCurrentUser() -> User? {
        return auth.currentUser
    }
    
    // MARK: - 사용자 정보 업데이트
    
    /// 사용자 정보를 업데이트합니다.
    /// - Parameter field: 업데이트할 사용자 필드 (`email`, `phoneNumber`, `password`)
    /// - Throws: 유효성 검사 실패나 인증 오류 발생 시 예외를 던집니다.
    func updateUser(_ field: UserUpdateField) async throws {
        do {
            let attributes: UserAttributes

            switch field {
            case .email(let email):
                attributes = UserAttributes(email: email)

            case .phoneNumber(let phoneNumber):
                let digits = phoneNumber.filter { $0.isNumber }

                guard digits.count == 10 || digits.count == 11 else {
                    throw LoginManagerError.invalidPhoneNumber
                }

                let internationalNumber = "+82" + digits.dropFirst(1)
                attributes = UserAttributes(phone: internationalNumber)

            case .password(let password):
                attributes = UserAttributes(password: password)
            }

            try await auth.update(user: attributes)
            
        } catch {
            throw mapAuthError(error)
        }
    }
    
    // MARK: - 재인증
    
    /// 익명으로 재인증을 수행합니다.
    func reAuthenticate() async throws { // 아직 사용하지 않음
        do {
            try await auth.signInAnonymously()
        } catch {
            throw mapAuthError(error)
        }
    }
    
    // MARK: - 오류 매핑
    
    /// Supabase 오류를 `LoginManagerError`로 매핑합니다.
    /// - Parameter error: 발생한 오류
    /// - Returns: 매핑된 `LoginManagerError`
    private func mapAuthError(_ error: Error) -> LoginManagerError {
        if let authError = error as? AuthError {
            switch authError.message {
            case "Invalid login credentials":
                return .invalidCredentials
            case "Email not confirmed":
                return .emailNotConfirmed
            case "User already registered":
                return .userAlreadyExists
            case "User not found":
                return .userNotFound
            case "Invalid phone number format (E.164 required)":
                return .invalidPhoneNumber
            case "Rate limit exceeded":
                return .rateLimitExceeded
            case "Missing email or phone":
                return .missingEmailOrPhone
            case "Invalid refresh token":
                return .invalidRefreshToken
            case "Invalid claim: missing sub":
                return .invalidClaim
            default:
                print("Unhandled AuthError: \(authError.message)")
                return .unknownError(message: authError.message)
            }
        }
        print("Unknown error: \(error.localizedDescription)")
        return .unknownError(message: error.localizedDescription)
    }
}


