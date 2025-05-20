//
//  ChatResponse.swift
//  SlowStarter
//
//  Created by 멘태 on 5/14/25.
//

import Foundation

struct Part: Codable {
    let text: String
}

struct Content: Codable {
    let role: String
    let parts: [Part]
}

struct MessageRequest: Codable {
    let contents: [Content]
}
