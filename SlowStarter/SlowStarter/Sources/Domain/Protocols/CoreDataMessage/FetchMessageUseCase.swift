//
//  FetchMessageUseCase.swift
//  SlowStarter
//
//  Created by 멘태 on 5/19/25.
//

protocol FetchMessageUseCase {
    func execute() async throws -> [Message]
}

class DefaultFetchMessageUseCase: FetchMessageUseCase {
    private let repository: CoreDataMessageRepository
    
    init(repository: CoreDataMessageRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [Message] {
        return try await repository.fetchMessages()
    }
}
