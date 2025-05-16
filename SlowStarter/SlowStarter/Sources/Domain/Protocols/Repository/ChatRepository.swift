//
//  ChatAPIRepository.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

protocol ChatRepository {
    func chat(text: String) async throws -> Message
    func summary(text: String) async throws -> String
}
