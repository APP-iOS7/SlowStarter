import Foundation


class LoginViewModel {
    private let dataManager = SupabaseDataManager.shared
    private let coredataManager = CoreDataManager.shared
    
    func login(email: String, password: String) async throws {
        try await dataManager.login(email: email, password: password)
        let user = try await dataManager.fetchUserInfo()
        
        let _ = coredataManager.createUserInfo(userId: user?.id ?? "", name: user?.name ?? "")
        
        let result = coredataManager.fetchUserInfo()
        for a in result {
            print(a)
        }
        
    }
    

}
