import Foundation
import Supabase

//TODO: 필요에 의해 변경하면 될듯

class SupabaseDataManager {
    private var client: SupabaseClient?
    private var databaseManager: DataBaseManager?
    private var storageManager: StorageManager?
    private var loginManager: LoginManager?
    
    static let shared = SupabaseDataManager()
    
    private init() {
        let supabaseURLString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_API_KEY") as? String
        
        if let urlString = supabaseURLString,
           let url = URL(string: urlString),
           let key = supabaseKey,
           !key.isEmpty {
            client = SupabaseClient(supabaseURL: url, supabaseKey: key)
            if let client = client {
                databaseManager = DataBaseManager(client: client)
                loginManager = LoginManager(client: client)
                storageManager = StorageManager(client: client)
            }
        } else {
            client = nil
            databaseManager = nil
            loginManager = nil
            storageManager = nil
            print("Config Key is empty")
        }
    }
    
    //MARK: Auth
    /// 지정된 이메일로 OTP를 전송합니다.
    func sendOtpToEmail(_ email: String) async throws {
        guard let loginManager = loginManager else { throw LoginManagerError.unknownError(message: "LoginManager not initialized") }
        try await loginManager.sendOTP(email: email)
    }
    
    /// 이메일과 OTP 토큰으로 사용자를 검증합니다.
    func checkOtpForEmail(_ email: String, otp: String) async throws {
        guard let loginManager = loginManager else { throw LoginManagerError.unknownError(message: "LoginManager not initialized") }
        try await loginManager.checkOTP(email: email, OTP: otp)
    }
    
    func checkEmailExists(_ email: String) async throws -> Bool {
        guard let databaseManager = databaseManager else {
            throw DatabaseError.unknown
        }
        
        do {
            let existingUser: [Users] = try await databaseManager.fetchData(as: Users.self, select: "user_id, email", conditionColumn: "email", conditionValue: email)
            return !existingUser.isEmpty
        } catch let error as DatabaseError {
            throw error
        }
    }
    
    /// 현재 인증된 사용자의 정보를 가져옵니다.
    func getCurrentAuthenticatedUser() -> Users? {
        guard let supabaseUser = loginManager?.getCurrentUser() else {
            return nil
        }
        
        let userId = supabaseUser.id.uuidString
        let email = supabaseUser.email
        let createdAt = supabaseUser.createdAt
        
        var name: String? = nil
        var nickname: String? = nil
        var profileImageURL: String? = nil
        // var age: Int? = nil // age 변수 제거
        
        let metadata = supabaseUser.userMetadata
        
        if let nameValue = metadata["full_name"] {
            if case .string(let metaName) = nameValue {
                name = metaName
            }
        }
        
        if let nicknameValue = metadata["nickname"] {
            if case .string(let metaNickname) = nicknameValue {
                nickname = metaNickname
            }
        }
        
        if let profileURLValue = metadata["profile_image_url"] { // 또는 "avatar_url"
            if case .string(let metaProfileURL) = profileURLValue {
                profileImageURL = metaProfileURL
            }
        }
        
        // age 관련 로직 완전 제거
        
        return Users(
            userId: userId,
            name: name,
            nickname: nickname,
            email: email,
            profileImageURL: profileImageURL,
            createdAt: createdAt
        )
    }
    
    /// 현재 인증된 사용자의 세션 정보를 서버에서 가져옵니다. (필요시)
    func fetchCurrentUserSession() async throws -> User? {
        guard let loginManager = loginManager else { throw LoginManagerError.unknownError(message: "LoginManager not initialized") }
        return try await loginManager.getCurrentUserInSession()
    }
    
    /// 현재 사용자의 특정 필드(비밀번호 등)를 업데이트합니다.
    func updateUserField(_ field: UserUpdateField) async throws {
        guard let loginManager = loginManager else { throw LoginManagerError.unknownError(message: "LoginManager not initialized") }
        try await loginManager.updateUser(field)
    }
    
    func login(email: String, password: String) async throws {
        guard let loginManager = loginManager else { throw LoginManagerError.unknownError(message: "LoginManager not initialized") }
        
        do {
            try await loginManager.login(email: email, password: password)
        } catch {
            throw error
        }
    }
    
    
    // MARK: DataBase
    func insertData<T>(_ data: T) async -> Bool {
        guard let databaseManager = databaseManager else {
            print("DatabaseManager not initialized.")
            return false
        }
        
        do {
            try await databaseManager.insertData(as: Users.self, data: data as! Users)
            return true
        } catch {
            print("error: \(error)")
            return false
        }
}

func fetchData<T>(_ type: T.Type) -> [T]? {
    
    return []
}

func deleteData<T>(_ data: T) -> Bool {
    
    return true
}

func updateData<T>(_ data: T) -> Bool {
    
    return true
}

func insertFile(file: Data) -> Bool {
    
    return true
}

func fetchFile(filePath: String) -> Data? {
    
    return Data()
}

func createSignedURL(filePath: String) -> URL? {
    
    return URL(string: "")
}
}
