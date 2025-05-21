//
//  SummaryChatMessageUseCase.swift
//  SlowStarter
//
//  Created by 멘태 on 5/16/25.
//

protocol SummaryUseCase {
    func execute(message: AIChatMessage) async throws -> AIChatMessage
}
