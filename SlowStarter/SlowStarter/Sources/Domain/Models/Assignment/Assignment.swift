import Foundation
import UIKit
import Kingfisher

struct Assignment: Identifiable, Equatable, Comparable {
    var id : String = UUID().uuidString
    var memo: String
    var image: UIImage
    let date: Date // 생성 시점에 날짜를 받도록 변경
    
    // MARK: - Comparable Protocol Conformance
    
    // 1. Equatable 준수 (id가 같으면 같은 객체로 판단)
    static func == (lhs: Assignment, rhs: Assignment) -> Bool {
        return lhs.id == rhs.id
    }
    
    // 2. Comparable 준수 (date를 기준으로 정렬)
    // 날짜가 오래된 것이 더 "작다" (오름차순 정렬 기준)
    static func < (lhs: Assignment, rhs: Assignment) -> Bool {
        return lhs.date < rhs.date
    }
    
    // MARK: - Sample Data
    
    static let sampleAssignments: [Assignment] = [
        Assignment(
            memo: "첫 번째 과제: 아이디어 스케치",
            image: UIImage(systemName: "pencil.and.outline") ?? UIImage(),
            date: Date().addingTimeInterval(-86400 * Double.random(in: 1...10)) // 1~10일 전의 랜덤 날짜
        ),
        Assignment(
            memo: "두 번째 과제: 프로토타입 제작",
            image: UIImage(systemName: "hammer.fill") ?? UIImage(),
            date: Date().addingTimeInterval(-86400 * Double.random(in: 1...10))
        ),
        Assignment(
            memo: "세 번째 과제: 사용자 테스트",
            image: UIImage(systemName: "person.3.fill") ?? UIImage(),
            date: Date().addingTimeInterval(-86400 * Double.random(in: 1...10))
        ),
        Assignment(
            memo: "네 번째 과제: 디자인 수정",
            image: UIImage(systemName: "paintbrush.pointed.fill") ?? UIImage(),
            date: Date().addingTimeInterval(-86400 * Double.random(in: 1...10))
        ),
        Assignment(
            memo: "다섯 번째 과제: 최종 발표 준비",
            image: UIImage(systemName: "speaker.wave.2.fill") ?? UIImage(),
            date: Date().addingTimeInterval(-86400 * Double.random(in: 1...10))
        )
    ]
}


extension Assignment {
    // ✅ (개선) UserAssignment -> Assignment 변환
    // static 키워드를 붙여 타입 자체에서 호출할 수 있도록 변경
    static func from(userAssignment: UserAssignment) async throws -> Assignment {
        guard let urlString = userAssignment.imageURL, let url = URL(string: urlString) else {
            throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Invalid image URL"])
        }
        
        // Kingfisher를 사용해 비동기적으로 이미지 다운로드
        let resource = KF.ImageResource(downloadURL: url)
        let image = try await KingfisherManager.shared.retrieveImage(with: resource)
        
        return Assignment(
            id: userAssignment.id, // 서버의 ID를 그대로 사용
            memo: userAssignment.description ?? "메모 없음",
            image: image,
            date: userAssignment.submittedAt ?? Date()
        )
    }
}
