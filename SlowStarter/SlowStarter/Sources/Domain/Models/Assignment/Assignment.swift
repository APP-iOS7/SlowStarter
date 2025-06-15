import Foundation
import UIKit
import Kingfisher

struct Assignment: Identifiable, Equatable, Comparable {
    var id: String = UUID().uuidString
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
    
    // ✅ (수정) UserAssignment -> Assignment 변환 함수
    static func from(userAssignment: UserAssignment) async -> Assignment { // ❌ throws 제거
        
        var finalImage: UIImage = UIImage(named: "sample_img") ?? UIImage() // 기본 이미지 설정
        
        // 1. imageURL이 유효한지 확인
        if let urlString = userAssignment.imageURL, let url = URL(string: urlString) {
            // 2. URL이 유효하다면 Kingfisher로 이미지 다운로드 시도
            let resource = KF.ImageResource(downloadURL: url)
            
            // `try? await`를 사용하여 다운로드 실패 시 에러를 던지는 대신 nil을 반환하도록 함
            if let result = try? await KingfisherManager.shared.retrieveImage(with: resource) {
                // 다운로드 성공 시, 결과 이미지로 교체
                finalImage = result.image
            }
            // 다운로드 실패 시에는 맨 처음에 설정한 기본 이미지가 그대로 사용됨
        }
        
        // 3. 최종적으로 Assignment 객체를 생성하여 반환 (이제 이 함수는 절대 에러를 던지지 않음)
        return Assignment(
            id: userAssignment.id, // 서버의 ID를 그대로 사용
            memo: userAssignment.description ?? "메모 없음",
            image: finalImage,
            date: userAssignment.submittedAt ?? Date()
        )
    }
}
