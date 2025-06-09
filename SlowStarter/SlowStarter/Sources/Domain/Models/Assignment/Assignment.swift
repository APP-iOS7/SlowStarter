//
//  Assignment.swift
//  SlowStarter
//
//  Created by jdios on 5/21/25.
//

import Foundation
import UIKit
struct Assignment: Identifiable {
    let id = UUID()
    var memo: String
    var image: UIImage
    
    static let sampleAssignments: [Assignment] = [
        Assignment(memo: "첫 번째 과제: 아이디어 스케치", image: UIImage(systemName: "pencil.and.outline") ?? UIImage()),
        Assignment(memo: "두 번째 과제: 프로토타입 제작", image: UIImage(systemName: "hammer.fill") ?? UIImage()),
        Assignment(memo: "세 번째 과제: 사용자 테스트", image: UIImage(systemName: "person.3.fill") ?? UIImage()),
        Assignment(memo: "네 번째 과제: 디자인 수정", image: UIImage(systemName: "paintbrush.pointed.fill") ?? UIImage()),
        Assignment(memo: "다섯 번째 과제: 최종 발표 준비", image: UIImage(systemName: "speaker.wave.2.fill") ?? UIImage())
    ]
}
