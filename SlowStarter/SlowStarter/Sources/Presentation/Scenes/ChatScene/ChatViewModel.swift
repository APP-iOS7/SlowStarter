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
    private let sendAndReceivedUsecase: SendAndReceiveMessageUseCase
    private let summaryUsecase: SummaryMessageUseCase
    private var messages: [Message] = []
    
    var allMessages: [Message] {
        return messages
    }
    
    private var addMessageSubject: PassthroughSubject<Message.ID, ChatAPIError> = PassthroughSubject()
    var addMessagePublisher: AnyPublisher<Message.ID, ChatAPIError> {
        return addMessageSubject.eraseToAnyPublisher()
    }
    
    private var summaryMessageSubject: PassthroughSubject<Message.ID, ChatAPIError> = PassthroughSubject()
    var summaryMessagePublisher: AnyPublisher<Message.ID, ChatAPIError> {
        return summaryMessageSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initializer
    init(sendAndReceive: SendAndReceiveMessageUseCase, summary: SummaryMessageUseCase) {
        self.sendAndReceivedUsecase = sendAndReceive
        self.summaryUsecase = summary
    }
    
    // MARK: - Functions
    func message(with id: UUID) -> Message? {
        return messages.first { $0.id == id }
    }
    
    func didTapSendButton(text: String) {
        Task {
            do {
                let myMessage: Message = Message(text: text, isSended: true, timestamp: Date())
                messages.append(myMessage)
                addMessageSubject.send(myMessage.id)
                
                let newMessage = try await sendAndReceivedUsecase.execute(text: text)
                messages.append(newMessage)
                addMessageSubject.send(newMessage.id)
            } catch {
                if let apiError = error as? ChatAPIError {
                    addMessageSubject.send(completion: .failure(apiError))
                } else {
                    addMessageSubject.send(completion: .failure(.unknown))
                }
            }
        }
    }
    
    func didTapSummaryButton(index: Int, message: Message) {
        Task {
            do {
                let summaryMessage: Message = try await summaryUsecase.execute(message: message)
                messages[index] = summaryMessage
                summaryMessageSubject.send(summaryMessage.id)
            } catch {
                if let apiError = error as? ChatAPIError {
                    summaryMessageSubject.send(completion: .failure(apiError))
                } else {
                    summaryMessageSubject.send(completion: .failure(.unknown))
                }
            }
        }
    }
}
