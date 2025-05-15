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
    private let useCase: SendChatMessageUseCase
    
    private var subject: PassthroughSubject<ChatMessage, ChatAPIError> = PassthroughSubject()
    var chatPublisher: AnyPublisher<ChatMessage, ChatAPIError> {
        return subject.eraseToAnyPublisher()
    }
    
    // MARK: - Initializer
    init(useCase: SendChatMessageUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Functions
    func didTapSendButton(message: String) {
        Task {
            do {
                let myMessage: ChatMessage = ChatMessage(text: message, isSended: true, timestamp: Date())
                subject.send(myMessage)
                
                let newMessage = try await useCase.execute(message: message)
                subject.send(newMessage)
            } catch {
                print(error)
                if let apiError = error as? ChatAPIError {
                    subject.send(completion: .failure(apiError))
                } else {
                    print(type(of: error))
                    subject.send(completion: .failure(.unknown))
                }
            }
        }
    }
}
