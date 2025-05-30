import Foundation


class LoginViewModel {
    private let dataManager = SupabaseDataManager.shared
    
    func login(email: String, password: String) async throws {
        do {
            try await dataManager.login(email: email, password: password)
        } catch {
            print(error)
        }
    }
}
