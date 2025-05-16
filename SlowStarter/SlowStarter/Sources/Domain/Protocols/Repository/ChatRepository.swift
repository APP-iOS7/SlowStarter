//
//  ChatAPIRepository.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

protocol ChatRepository {
    func chat(texts: [String]) async throws -> Message
    func summary(texts: [String]) async throws -> String
}
