//
//  SlowChatViewModel.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import Foundation
import Combine

final class ChatViewModel: ObservableObject {
    // MARK: - Properties
    @Published var messages: [Messages] = []
    
    private let chatUseCase: DefaultChatUseCase
    private let summaryUseCase: DefaultSummaryUseCase
    
    private let coreDataManager: CoreDataManager
    
//    private let saveMessageUseCase: SaveMessageUseCase
//    private let fetchMessagesUseCase: FetchMessageUseCase
//    private let deleteMessageUseCase: DeleteMessageUseCase
//    private let updateMessageUseCase: UpdateMessageUseCase
    
    var allMessages: [Messages] {
        return messages
    }
    
    private var recentMessages: [String] {
        let size: Int = min(10, messages.count) // 10개, 그보다 적다면 있는 만큼
        return Array(messages[(messages.count - size)...]).map { $0.text } // 뒤에서부터 size 만큼 꺼냄
    }
    
    // MARK: - Initializer
//    init(chat: DefaultChatUseCase, summary: DefaultSummaryUseCase,
//         save: SaveMessageUseCase, fetch: FetchMessageUseCase,
//         delete: DeleteMessageUseCase, update: UpdateMessageUseCase) {
//        self.chatUseCase = chat
//        self.summaryUseCase = summary
//        self.saveMessageUseCase = save
//        self.fetchMessagesUseCase = fetch
//        self.deleteMessageUseCase = delete
//        self.updateMessageUseCase = update
//    }
    
    init(chat: DefaultChatUseCase, summary: DefaultSummaryUseCase, coreDataManager: CoreDataManager
         ) {
        self.chatUseCase = chat
        self.summaryUseCase = summary
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Functions
    func message(with id: UUID) -> Messages? {
        return messages.first { $0.id == id }
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
                let myMessage: Messages = Messages(text: text, isSended: true, timestamp: Date())
                messages.append(myMessage)
//                try await saveMessageUseCase.execute(myMessage) // CoreData에 보낸 메시지 저장
                try await coreDataManager.saveMessage(myMessage)
                
                // 대화의 맥락을 유지하기 위해 최근 메시지를 함께 보냄
                //TODO: 이부분 오류
//                let sendMessages: [String] = recentMessages
//                let newMessage = try await chatUseCase.execute(messages: sendMessages) // 답장 받아오기
//                messages.append(newMessage)
//                try await saveMessageUseCase.execute(newMessage) // CoreData에 답장 저장
//                try await coreDataManager.saveMessage(newMessage)
            } catch {
                if let apiError = error as? ChatAPIError {
                    
                } else {
                }
            }
        }
    }
    
    func didTapSummaryButton(index: Int, message: Messages) {
        Task {
            do {
                let summaryMessage: Messages = try await summaryUseCase.execute(message: message)
                messages[index] = summaryMessage
//                try await updateMessageUseCase.execute(summaryMessage)
                try await coreDataManager.updateMessage(summaryMessage)
            } catch {
                if let apiError = error as? ChatAPIError {
                } else {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
