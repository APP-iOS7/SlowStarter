//
//  SlowChatViewModel.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import Foundation

final class ChatViewModel: ObservableObject {
    // MARK: - Properties
    @Published var messages: [AIChatMessage] = []
    
    private let chatUseCase: DefaultChatUseCase
    private let summaryUseCase: DefaultSummaryUseCase
    
    private let coreDataManager: CoreDataManager
    
    private var recentMessages: [AIChatMessage] {
        let size: Int = min(10, messages.count) // 10개, 그보다 적다면 있는 만큼
        return Array(messages[(messages.count - size)...]) // 뒤에서부터 size 만큼 꺼냄
    }
    
    var messageIDs: [AIChatMessage.ID] {
        return messages.map { $0.id }
    }
    
    var numberOfMessages: Int {
        return messages.count
    }
    
    init(chat: DefaultChatUseCase, summary: DefaultSummaryUseCase, coreDataManager: CoreDataManager
         ) {
        self.chatUseCase = chat
        self.summaryUseCase = summary
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Functions
    func messageWith(id: UUID) -> AIChatMessage? {
        return messages.first { $0.id == id }
    }
    
    func messageAt(index: Int) -> AIChatMessage? {
        guard messages.indices.contains(index) else { return nil }
        return messages[index]
    }
    
    func fetchMessages() {
        Task {
            do {
                messages = try await coreDataManager.fetchMessages()
            } catch {
                
            }
        }
    }
    
    func didTapSendButton(text: String) {
        Task {
            do {
                let myMessage: AIChatMessage = AIChatMessage(text: text, isSended: true, timestamp: Date())
                messages.append(myMessage)
                try await coreDataManager.saveMessage(myMessage)
                
                // 대화의 맥락을 유지하기 위해 최근 메시지를 함께 보냄
                let sendMessages: [AIChatMessage] = recentMessages
                let newMessage = try await chatUseCase.execute(messages: sendMessages) // 답장 받아오기
                messages.append(newMessage)
                try await coreDataManager.saveMessage(newMessage) // CoreData에 답장 저장
            } catch {
                if let apiError = error as? ChatAPIError {
                    print(apiError)
                } else {
                    
                }
            }
        }
    }
    
    func didTapSummaryButton(index: Int, message: AIChatMessage) {
        Task {
            do {
                let summaryMessage: AIChatMessage = try await summaryUseCase.execute(message: message)
                messages[index] = summaryMessage
                try await coreDataManager.updateMessage(summaryMessage)
            } catch {
                if let apiError = error as? ChatAPIError {
                    print(apiError)
                } else {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
