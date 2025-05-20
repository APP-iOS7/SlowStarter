import Foundation
import Supabase

public final class DataBaseManager: DataBaseManagerProtocol {
    private var client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    //MARK: - Read
    /// 선택한 타입의 모든 값을 조회하는 함수입니다.
    ///
    /// - Parameter type: 조회할 모델 타입 (예: `User.self`)
    /// - Returns: 입력한 타입에 맞는 조회된 리스트 값 `[T]`
    /// - Throws: 네트워크 요청 중 발생한 오류를 던집니다.
    ///
    /// 예시:
    /// ```
    /// let users: [User] = try await networkManager.fetchData(as: User.self)
    /// ```
    func fetchData<T: Decodable>(as type: T.Type) async throws -> [T] {
        let tableName: String
        do {
            tableName = try self.tableName(for: type)
        }
        catch {
            throw error
        }
        
        do {
            let data: [T] = try await client
                .from(tableName)
                .select()
                .execute()
                .value
            
            return data
        }
        catch {
            print("FETCH ERROR: \(error.localizedDescription)")
            throw DatabaseError.unknown
        }
    }
    
    /// 선택한 타입의 원하는 컬럼의 값을 조회하는 함수입니다.
    ///
    /// - Parameters:
    ///   - type: 조회할 모델 타입 (예: `User.self`)
    ///   - select: 조회할 컬럼의 이름 (예: `"name, age"`)
    /// - Returns: 입력한 타입에 맞는 조회된 리스트 값 `[T]`
    /// - Throws: 네트워크 요청 중 발생한 오류를 던집니다.
    ///
    /// 예시:
    ///```
    ///Example.1 단일 column
    ///fetchData(as: User.self, select: "name")
    ///
    ///Example.2 멀티 column
    ///fetchData(as: User.self, select: "name, age ")
    ///
    ///Example.3 foreign 멀티 column
    ///fetchData(as: UserDetail.self, select: "address, Users(user_id) ")
    ///
    ///Example.4 foreign Count
    ///fetchData(as: UserDetail.self, select: "*, Users(count)")
    ///
    ///본인 스스로의 count는 isOnlyCount 옵션이 있는 함수를 사용
    ///```
    func fetchData<T: Decodable>(as type: T.Type, select: String) async throws -> [T] {
        let tableName: String
        do {
            tableName = try self.tableName(for: type)
        }
        catch {
            throw error
        }
        
        do {
            let data: [T] = try await client
                .from(tableName)
                .select(select)
                .execute()
                .value
            
            return data
        }
        catch {
            print("FETCH ERROR: \(error.localizedDescription)")
            throw DatabaseError.unknown
        }
    }
    
    /// 선택한 타입의 원하는 컬럼의 값을 리스트 형식으로 조회하는 함수입니다.
    ///
    /// - Parameters:
    ///   - type: 조회할 모델 타입 (예: `User.self`)
    ///   - select: 조회할 컬럼의 이름 리스트 (예: `["name", "age"]`)
    /// - Returns: 입력한 타입에 맞는 조회된 리스트 값 `[T]`
    /// - Throws: 네트워크 요청 중 발생한 오류를 던집니다.
    ///
    /// 예시:
    /// ```
    /// let users: [User] = try await networkManager.fetchListData(as: User.self, select: ["name", "age"])
    /// ```
    func fetchListData<T: Decodable>(as type: T.Type, select: [String]) async throws -> [T] {
        let tableName: String
        do {
            tableName = try self.tableName(for: type)
        }
        catch {
            throw error
        }
        
        let selectClause: String = select.joined(separator: ", ")
        
        do {
            let data: [T] = try await client
                .from(tableName)
                .select(selectClause)
                .execute()
                .value
            
            return data
        }
        catch {
            print("FETCH ERROR: \(error.localizedDescription)")
            throw DatabaseError.unknown
        }
    }
    
    /// 선택한 타입의 원하는 컬럼의 count 값을 조회하는 함수입니다.
    ///
    /// - Parameters:
    ///   - type: 조회할 모델 타입 (예: `User.self`)
    ///   - select: 조회할 컬럼의 이름 (예: `"id"`)
    ///   - isOnlyCount: `true`일 경우 count 값만 반환합니다.
    /// - Returns: 조회된 count 값 `Int`
    /// - Throws: 네트워크 요청 중 발생한 오류를 던집니다.
    ///
    /// 예시:
    /// ```
    /// let count: Int = try await networkManager.fetchData(as: User.self, select: "id", isOnlyCount: true)
    /// ```
    func fetchData<T: Decodable>(as type: T.Type, select: String, isOnlyCount: Bool) async throws -> Int {
        let tableName: String
        do {
            tableName = try self.tableName(for: type)
        }
        catch {
            throw error
        }
        
        do {
            let data = try await client
                .from(tableName)
                .select(select, head: isOnlyCount, count: .exact)
                .execute()
            
            guard let count = data.count else {
                throw DatabaseError.unknown
            }
            return count
            
        }
        catch {
            print("FETCH ERROR: \(error.localizedDescription)")
            throw DatabaseError.unknown
        }
    }
    
    /// 선택한 타입의 필터를 적용하여 값을 조회하는 함수입니다.
    ///
    /// - Parameters:
    ///   - type: 조회할 모델 타입 (예: `User.self`)
    ///   - select: 조회할 컬럼의 이름 (예: `"name, age"`)
    ///   - conditionColumn: 필터를 적용할 컬럼의 이름 (예: `"age"`)
    ///   - conditionValue: 필터 조건 값 (예: `30`)
    /// - Returns: 입력한 타입에 맞는 조회된 리스트 값 `[T1]`
    /// - Throws: 네트워크 요청 중 발생한 오류를 던집니다.
    ///
    /// 예시:
    /// ```
    /// let users: [User] = try await networkManager.fetchData(as: User.self, select: "name, age", conditionColumn: "age", conditionValue: 30)
    /// ```
    func fetchData<T1: Decodable, T2:Decodable>(as type: T1.Type, select: String, conditionColumn: String, conditionValue: T2) async throws -> [T1] {
        let tableName: String
        do {
            tableName = try self.tableName(for: type)
        }
        catch {
            throw error
        }
        
        do {
            let data: [T1] = try await client
                .from(tableName)
                .select(select)
                .eq(conditionColumn, value: conditionValue as! PostgrestFilterValue)
                .execute()
                .value
            
            return data
        }
        catch {
            print("FETCH ERROR: \(error.localizedDescription)")
            throw DatabaseError.unknown
        }
    }
    
    
    //MARK: - Create
    
    /// 단일 데이터를 삽입하는 함수입니다.
    ///
    /// - Parameters:
    ///   - type: 삽입할 모델 타입 (예: `User.self`)
    ///   - data: 삽입할 데이터 인스턴스
    /// - Throws: 네트워크 요청 중 발생한 오류를 던집니다.
    ///
    /// 예시:
    /// ```
    /// let newUser = User(name: "John", age: 30)
    /// try await networkManager.insertData(as: User.self, data: newUser)
    /// ```
    func insertData<T: Encodable>(as type: T.Type, data: T) async throws {
        let tableName: String
        do {
            tableName = try self.tableName(for: type)
            print(tableName)
        }
        catch {
            throw error
        }
        
        do {
            try await client
                .from(tableName)
                .insert(data)
                .execute()
        }
        catch {
            print("FETCH ERROR: \(error.localizedDescription)")
            throw DatabaseError.unknown
        }
    }
    
    /// 데이터 리스트를 한 번에 삽입하는 함수입니다.
    ///
    /// - Parameters:
    ///   - type: 삽입할 모델 타입 (예: `User.self`)
    ///   - data: 삽입할 데이터 리스트
    /// - Throws: 네트워크 요청 중 발생한 오류를 던집니다.
    ///
    /// 예시:
    /// ```
    /// let users = [User(name: "John", age: 30), User(name: "Jane", age: 25)]
    /// try await networkManager.insertListData(as: User.self, data: users)
    /// ```
    func insertListData<T: Encodable>(as type: T.Type, data: [T]) async throws {
        let tableName: String
        do {
            tableName = try self.tableName(for: type)
        }
        catch {
            throw error
        }
        
        do {
            try await client
                .from(tableName)
                .insert(data)
                .execute()
        }
        catch {
            print("FETCH ERROR: \(error.localizedDescription)")
            throw DatabaseError.unknown
        }
    }
    
    //// 단일 데이터를 삽입하고 삽입된 데이터를 반환하는 함수입니다.
    ///
    /// - Parameters:
    ///   - type: 삽입할 모델 타입 (예: `User.self`)
    ///   - data: 삽입할 데이터 인스턴스
    /// - Returns: 삽입된 데이터 인스턴스
    /// - Throws: 네트워크 요청 중 발생한 오류를 던집니다.
    ///
    /// 예시:
    /// ```
    /// let newUser = User(name: "John", age: 30)
    /// let insertedUser = try await networkManager.insertAndSelectData(as: User.self, data: newUser)
    /// ```
    func insertAndSelectData<T: Encodable>(as type: T.Type, data: T) async throws -> T {
        let tableName: String
        do {
            tableName = try self.tableName(for: type)
        }
        catch {
            throw error
        }
        
        do {
            let returnedData: T = try await client
                .from(tableName)
                .insert(data)
                .select()
                .single()
                .execute()
                .value as! T
            return returnedData
        }
        catch {
            print("FETCH ERROR: \(error.localizedDescription)")
            throw DatabaseError.unknown
        }
    }
    
    //MARK: - Update
    
    /// 데이터를 업데이트하는 함수입니다.
    ///
    /// - Parameters:
    ///   - type: 업데이트할 모델 타입 (예: `User.self`)
    ///   - toUpdateData: 업데이트할 데이터 딕셔너리
    ///   - conditionColumn: 필터를 적용할 컬럼의 이름 (예: `"id"`)
    ///   - conditionValue: 필터 조건 값 (예: `1`)
    /// - Throws: 네트워크 요청 중 발생한 오류를 던집니다.
    ///
    /// 예시:
    /// ```
    /// let updateData: [String: Any] = ["name": "John Doe"]
    /// try await networkManager.updateData(as: User.self, toUpdateData: updateData, conditionColumn: "id", conditionValue: 1)
    /// ```
//    func updateData<T1: Encodable, T2: PostgrestFilterValue>(as type: T1.Type, toUpdateData: [String: Any], conditionColumn: String, conditionValue: T2) async throws {
//        let tableName = try tableName(for: type)
//
//        let encodableData = toUpdateData.mapValues { value -> AnyEncodable in
//            if let encodable = value as? Encodable {
//                return AnyEncodable(encodable)
//            } else {
//                fatalError("Value \(value) does not conform to Encodable")
//            }
//        }
//
//        do {
//            try await client
//                .from(tableName)
//                .update(encodableData)
//                .eq(conditionColumn, value: conditionValue)
//                .execute()
//        } catch {
//            print("FETCH ERROR: \(error.localizedDescription)")
//            throw DatabaseError.unknown
//        }
//    }
    
    func updateData<T1: Encodable, T2: Encodable>(as type: T1.Type, toUpdateData: [String: Any], conditionColumn: String, conditionValue: T2) async throws {
        let tableName = try tableName(for: type)
        
        let encodableData = toUpdateData.mapValues { value -> AnyEncodable in
            if let encodable = value as? Encodable {
                return AnyEncodable(encodable)
            } else {
                fatalError("Value \(value) does not conform to Encodable")
            }
        }
        
        do {
            try await client
                .from(tableName)
                .update(encodableData)
                .eq(conditionColumn, value: conditionValue as! PostgrestFilterValue)
                .execute()
        } catch {
            print("FETCH ERROR: \(error.localizedDescription)")
            throw DatabaseError.unknown
        }
    }
    
    //MARK: - Delete
    
    /// 데이터를 업데이트하는 함수입니다.
    ///
    /// - Parameters:
    ///   - type: 업데이트할 모델 타입 (예: `User.self`)
    ///   - toUpdateData: 업데이트할 데이터 딕셔너리
    ///   - conditionColumn: 필터를 적용할 컬럼의 이름 (예: `"id"`)
    ///   - conditionValue: 필터 조건 값 (예: `1`)
    /// - Throws: 네트워크 요청 중 발생한 오류를 던집니다.
    ///
    /// 예시:
    /// ```
    /// let updateData: [String: Any] = ["name": "John Doe"]
    /// try await networkManager.updateData(as: User.self, toUpdateData: updateData, conditionColumn: "id", conditionValue: 1)
    /// ```
    func deleteData<T1, T2: Encodable>(as type: T1.Type, conditionColumn: String, conditionValue: T2) async throws {
        let tableName: String
        do {
            tableName = try self.tableName(for: type)
        }
        catch {
            throw error
        }
        
        do {
            try await client
                .from(tableName)
                .delete()
                .eq(conditionColumn, value: conditionValue as! PostgrestFilterValue)
                .execute()
        }
        catch {
            print("FETCH ERROR: \(error.localizedDescription)")
            throw DatabaseError.unknown
        }
    }
    
    
    // MARK: - Table Name Resolver
    func tableName<T>(for type: T.Type) throws -> String {
        switch type {
        case is Users.Type: return "users"
        case is UserDetail.Type: return "user_detail"
        case is UserSetting.Type: return "user_settings"
        case is UserSubscription.Type: return "user_subscriptions"
        case is UserAssignment.Type: return "user_assignments"
        case is UserAttendance.Type: return "user_attendance"
        case is UserPointLog.Type: return "user_point_log"
        case is UserItem.Type: return "user_items"
        case is UserPayment.Type: return "user_payments"
            
        case is Instructor.Type: return "instructors"
        case is InstructorDetail.Type: return "instructor_detail"
            
        case is Lecture.Type: return "lectures"
        case is LectureIntroVideo.Type: return "lecture_intro_videos"
        case is LectureIntroImage.Type: return "lecture_intro_images"
            
        case is ChatRoom.Type: return "chat_rooms"
        case is ChatMessage.Type: return "chat_messages"
            
        case is VOD.Type: return "vods"
        case is Item.Type: return "items"
            
        default:
            throw DatabaseError.unsupportedType("\(type)")
        }
    }
    
    
}
