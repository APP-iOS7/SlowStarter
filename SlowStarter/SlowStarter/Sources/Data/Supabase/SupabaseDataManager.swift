import Foundation
import Supabase

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

    /// 로그아웃을 수행합니다.
    func logout() async throws {
        try await loginManager?.logout()
    }

    /// 지정된 이메일로 OTP를 전송합니다.
    /// - Parameter email: OTP를 받을 사용자 이메일 주소
    func sendOtpToEmail(_ email: String) async throws {
        guard let loginManager = loginManager else { throw LoginManagerError.unknownError(message: "LoginManager not initialized") }
        try await loginManager.sendOTP(email: email)
    }

    /// 이메일과 OTP 토큰으로 사용자를 검증합니다.
    /// - Parameters:
    ///   - email: 인증할 사용자 이메일 주소
    ///   - otp: 이메일로 받은 OTP 코드
    func checkOtpForEmail(_ email: String, otp: String) async throws {
        guard let loginManager = loginManager else { throw LoginManagerError.unknownError(message: "LoginManager not initialized") }
        try await loginManager.checkOTP(email: email, OTP: otp)
    }

    /// 이메일이 이미 등록되어 있는지 확인합니다.
    /// - Parameter email: 확인할 이메일 주소
    /// - Returns: 이메일이 존재하면 true, 아니면 false
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
    /// - Returns: 사용자 정보(Users) 또는 nil
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

        if let profileURLValue = metadata["profile_image_url"] {
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

    /// 현재 인증된 사용자의 세션 정보를 가져옵니다.
    /// - Returns: 세션에 존재하는 사용자(User)
    func fetchCurrentUserSession() async throws -> User? {
        guard let loginManager = loginManager else { throw LoginManagerError.unknownError(message: "LoginManager not initialized") }
        return try await loginManager.getCurrentUserInSession()
    }

    /// 현재 사용자의 특정 필드를 업데이트합니다.
    /// - Parameter field: 업데이트할 필드(UserUpdateField)
    func updateUserField(_ field: UserUpdateField) async throws {
        guard let loginManager = loginManager else { throw LoginManagerError.unknownError(message: "LoginManager not initialized") }
        try await loginManager.updateUser(field)
    }

    /// 이메일과 비밀번호로 로그인합니다.
    /// - Parameters:
    ///   - email: 사용자 이메일
    ///   - password: 사용자 비밀번호
    func login(email: String, password: String) async throws {
        guard let loginManager = loginManager else { throw LoginManagerError.unknownError(message: "LoginManager not initialized") }

        do {
            try await loginManager.login(email: email, password: password)
        } catch {
            throw error
        }
    }

    /// 현재 계정을 삭제합니다.
    func deleteAccount() async throws {
        do {
            try await loginManager?.getCurrentSession()
            try await loginManager?.deleteUser()
            try await loginManager?.logout()
        } catch {
            print("delete error")
            throw error
        }
    }

    // MARK: DataBase

    /// 사용자 정보 및 기본 데이터를 생성합니다.
    /// - Parameter data: 사용자 데이터 (Users 타입)
    /// - Returns: 성공 여부
    func createUserInfo<T>(_ data: T) async -> Bool {
        guard let databaseManager = databaseManager else {
            print("DatabaseManager not initialized.")
            return false
        }

        do {
            if let user = data as? Users {
                try await databaseManager.insertData(as: Users.self, data: user)

                let pointLog = UserPointLog.zero(userId: user.userId)
                let setting = UserSetting.zero(userId: user.userId, notifyChat: true, notifyPush: true)

                try await databaseManager.insertData(as: UserPointLog.self, data: pointLog)
                try await databaseManager.insertData(as: UserSetting.self, data: setting)
            }
            return true
        } catch {
            print("error: \(error)")
            return false
        }
    }

    /// 현재 로그인된 사용자 정보를 가져옵니다.
    /// - Returns: 사용자 정보(Users)
    func fetchUserInfo() async throws -> Users? {
        let authUser = try await fetchCurrentUserSession()

        guard let userId = authUser?.id else {
            throw LoginManagerError.userNotFound
        }

        guard let user = try await databaseManager?.fetchData(
            as: Users.self,
            select: "*",
            conditionColumn: "user_id",
            conditionValue: userId
        ) else {
            return nil
        }

        return user[0]
    }
    
    /// 특정 사용자의 지정된 기간 동안의 출석 기록을 조회합니다.
    /// - Parameters:
    ///   - userId: 조회할 사용자 ID
    ///   - from: 조회 시작 날짜 (yyyy-MM-dd)
    ///   - to: 조회 종료 날짜 (yyyy-MM-dd)
    /// - Returns: UserAttendance 배열
    func fetchUserAttendances(userId: String, from: String, to: String) async throws -> [UserAttendance] {
        guard let databaseManager = databaseManager else {
            throw DatabaseError.unknown
        }
        
        return try await databaseManager.fetchDateRangeData(
            as: UserAttendance.self,
            select: "*",
            filterColumn: "attended_date",
            from: from,
            to: to,
            userId: userId
        )
    }
    
    func fetchUserPayments() async throws -> [UserPayment] {
        guard let currentUser = try await fetchCurrentUserSession() else {
            throw LoginManagerError.userNotFound
        }

        guard let databaseManager = databaseManager else {
            throw DatabaseError.unknown
        }

        return try await databaseManager.fetchData(
            as: UserPayment.self,
            select: "*",
            conditionColumn: "user_id",
            conditionValue: currentUser.id
        )
    }
    
    func fetchCourseHistories() async throws -> [UserCourseHistory] {
        guard let currentUser = try await fetchCurrentUserSession() else {
            throw LoginManagerError.userNotFound
        }

        guard let databaseManager = databaseManager else {
            throw DatabaseError.unknown
        }

        return try await databaseManager.fetchData(
            as: UserCourseHistory.self,
            select: "*",
            conditionColumn: "user_id",
            conditionValue: currentUser.id
        )
    }

    func fetchLectureList() async throws -> [Lecture] {
        guard let databaseManager = databaseManager else {
            throw DatabaseError.unknown
        }
        
        return try await databaseManager.fetchJoinedData(
            from: "lectures",
            select: "*"
        )
    }
    
    func fetchLectureimages() async throws -> [LectureIntroImage] {
        guard let databaseManager = databaseManager else {
            throw DatabaseError.unknown
        }
        
        return try await databaseManager.fetchJoinedData(
            from: "lecture_intro_images",
            select: "*"
        )
    }
    
    func fetchLectureVideos() async throws -> [LectureIntroVideo] {
        guard let databaseManager = databaseManager else {
            throw DatabaseError.unknown
        }
        
        return try await databaseManager.fetchJoinedData(
            from: "lecture_intro_videos",
            select: "*"
        )
    }

    // MARK: - Storage

    /// 지정된 경로의 프로필 이미지를 삭제합니다.
    /// - Parameters:
    ///   - bucket: 저장소 버킷 이름
    ///   - filePaths: 삭제할 파일 경로 목록
    func deleteProfileImage(bucket: String, filePaths: [String]) async {
        try? await storageManager?.deleteFile(bucket: bucket, filePaths: filePaths)
    }

    /// 공개 이미지 URL을 생성합니다.
    /// - Parameters:
    ///   - bucket: 저장소 버킷 이름
    ///   - filePath: 이미지 경로
    /// - Returns: 공개 접근 가능한 URL
    func createPublicImageURL(bucket: String, filePath: String) -> URL? {
        let url = try? storageManager?.createPublicUrl(bucket: bucket, filePath: filePath)
        return url
    }

    /// 프로필 이미지를 업로드합니다.
    /// - Parameters:
    ///   - bucket: 저장소 버킷 이름
    ///   - filepath: 저장될 파일 경로
    ///   - file: 업로드할 파일 데이터
    ///   - upsert: 기존 파일 덮어쓰기 여부
    ///   - cacheControl: 캐시 제어 값 (기본값: "3600")
    func uploadProfileImage(bucket: String, filepath: String, file: Data, upsert: Bool, cacheControl: String = "3600") async throws {
        guard let storageManager = storageManager else {
            throw StorageManagerError.unknown("StorageManager not initialized")
        }
        let fileExtension = URL(fileURLWithPath: filepath).pathExtension.lowercased()
        guard StorageType(rawValue: fileExtension) != nil else {
            print("Warning: Unknown file type for \(filepath). Defaulting to application/octet-stream or consider throwing error.")
            try await storageManager.uploadFile(bucket: bucket, filepath: filepath, file: file, upsert: upsert)
            return
        }
        try await storageManager.uploadFile(bucket: bucket, filepath: filepath, file: file, upsert: upsert)
    }

    /// 사용자 프로필 정보를 업데이트합니다.
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - details: 업데이트할 필드 정보 딕셔너리
    func updateUserProfile(userId: String, details: [String: Any]) async throws {
        guard let databaseManager = databaseManager else {
            throw DatabaseError.unknown
        }
        try await databaseManager.updateData(as: Users.self, toUpdateData: details, conditionColumn: "user_id", conditionValue: userId)
    }
}
