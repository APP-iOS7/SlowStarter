
import Foundation

struct DefaultChatUseCase: ChatUseCase {
    let repository: ChatRepository
    
    func execute(texts: [String]) async throws -> Message {
        return try await repository.chat(texts: texts)
    }
}
