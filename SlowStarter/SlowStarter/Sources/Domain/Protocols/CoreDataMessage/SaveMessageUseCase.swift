//
//  SaveMessageUseCase.swift
//  SlowStarter
//
//  Created by 멘태 on 5/19/25.
//

protocol SaveMessageUseCase {
    func execute(_ message: Message) async throws
}

class DefaultSaveMessageUseCase: SaveMessageUseCase {
    private let repository: CoreDataMessageRepository
    
    init(repository: CoreDataMessageRepository) {
        self.repository = repository
    }
    
    func execute(_ message: Message) async throws {
        try await repository.saveMessage(message)
    }
}
