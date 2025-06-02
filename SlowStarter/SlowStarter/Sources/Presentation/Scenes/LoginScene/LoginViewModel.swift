import Foundation


class LoginViewModel {
    private let dataManager = SupabaseDataManager.shared
    
    func login(email: String, password: String) async throws {
        try await dataManager.login(email: email, password: password)
    }
}
