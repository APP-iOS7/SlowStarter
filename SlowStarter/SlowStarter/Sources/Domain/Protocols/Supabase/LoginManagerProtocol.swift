
import Foundation

protocol LoginManagerProtocol {
    func signUp(email: String, password: String) async throws
    func login(email: String, password: String) async throws
    func logout() async throws
    func updateUser(_ field: UserUpdateField) async throws
}
