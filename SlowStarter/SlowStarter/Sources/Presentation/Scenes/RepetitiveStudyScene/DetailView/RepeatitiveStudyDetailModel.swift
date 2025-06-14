//
//  RepeatitiveStudyDetailViewModel.swift
//  SlowStarter
//
//  Created by jdios on 5/23/25.
//

import Foundation
import UIKit

struct RepeatLearnData: Equatable {
    static func == (lhs: RepeatLearnData, rhs: RepeatLearnData) -> Bool {
        return lhs.lectureTitle == rhs.lectureTitle
    }
    
    static let sample = RepeatLearnData(lectureTitle: "예시 강의명",
                                        lectureDescription: "기타 정보 / 기타 정보 / 기타 정보 / 영상길이",
                                        lectureURL: bigbunny,
                                        weeklyProgress: 1,
                                        assignments: Assignment.sampleAssignments)
    
    var lectureTitle: String
    var lectureDescription: String
    var lectureURL: URL
    var weeklyProgress: Int
    var assignments: [Assignment]
    var dailyAssignmentChecked: Bool = false //
    
    static let sampleDataset: [RepeatLearnData] = [
        RepeatLearnData(
            lectureTitle: "Big Buck Bunny: 기본 애니메이션 원리",
            lectureDescription: "Blender Foundation / 캐릭터 애니메이션 / 단편 코미디 / 9분 56초",
            lectureURL: bigbunny,
            weeklyProgress: 1,
            assignments: [Assignment.sampleAssignments[0], Assignment.sampleAssignments[1]] // 아이디어 스케치, 프로토타입 제작
        ),
        RepeatLearnData(
            lectureTitle: "Elephants Dream: 초현실적 스토리텔링",
            lectureDescription: "Blender Foundation / CGI 애니메이션 / 드라마 / 10분 54초",
            lectureURL: elephantsDream,
            weeklyProgress: 2,
            assignments: [Assignment.sampleAssignments[2]] // 사용자 테스트
        ),
        RepeatLearnData(
            lectureTitle: "For Bigger Blazes: 특수효과와 액션",
            lectureDescription: "Blender Cloud / VFX / 액션 시퀀스 / 15초",
            lectureURL: forBiggerBlazzes,
            weeklyProgress: 3,
            assignments: [] // 이 강의는 과제 없음
        ),
        RepeatLearnData(
            lectureTitle: "Sintel: 서사와 감정 표현",
            lectureDescription: "Blender Foundation / 판타지 애니메이션 / 감동 스토리 / 14분 48초",
            lectureURL: sizzleReel,
            weeklyProgress: 1, // Sintel.mp4
            assignments: Assignment.sampleAssignments // 모든 샘플 과제 포함
        ),
        RepeatLearnData(
            lectureTitle: "Tears of Steel: 실사 VFX 통합",
            lectureDescription: "Blender Institute / SF 실사 단편 / 로봇 액션 / 12분 14초",
            lectureURL: tearsOfSteel,
            weeklyProgress: 2,
            assignments: [Assignment.sampleAssignments[3], Assignment.sampleAssignments[4]] // 디자인 수정, 최종 발표 준비
        ),
        RepeatLearnData(
            lectureTitle: "자동차 쇼핑: 100만원으로 어떤 차를?",
            lectureDescription: "Top Gear (샘플) / 자동차 리뷰 / 예능 / 45초",
            lectureURL: whatCarCanYouGet,
            weeklyProgress: 0,
            assignments: [Assignment.sampleAssignments[0]] // 아이디어 스케치 (예시)
        ),
        RepeatLearnData(
            lectureTitle: "불런 참가기: 레이싱 다큐",
            lectureDescription: "Top Gear (샘플) / 자동차 레이싱 / 다큐멘터리 / 1분",
            lectureURL: weAreGoingOnBullrun,
            weeklyProgress: 0,
            assignments: [] // 과제 없음
        ),
        // 기존 sample을 목록에 포함시키거나, 약간 변형해서 추가
        RepeatLearnData(
            lectureTitle: "강의 복습: Big Buck Bunny 심층 분석",
            lectureDescription: "애니메이션 기법 해설 / 학생용 / 9분 56초",
            lectureURL: bigbunny,
            weeklyProgress: 1, // 중복 URL 사용 가능 (다른 강의 내용으로 간주)
            assignments: Array(Assignment.sampleAssignments.suffix(2)) // 마지막 2개 과제
        ),
        RepeatLearnData(
            lectureTitle: "단편 영화 제작 워크플로우: Elephants Dream",
            lectureDescription: "제작 과정 소개 / 기술 해설 / 10분 54초",
            lectureURL: elephantsDream,
            weeklyProgress: 2,
            assignments: [Assignment.sampleAssignments[1], Assignment.sampleAssignments[2], Assignment.sampleAssignments[3]]
        ),
        RepeatLearnData(
            lectureTitle: "VFX 샷 만들기: For Bigger Blazes",
            lectureDescription: "짧은 VFX 제작 팁 / 초급자용 / 15초",
            lectureURL: forBiggerBlazzes,
            weeklyProgress: 3,
            assignments: [Assignment.sampleAssignments[0]]
        )
    ]
}

extension RepeatLearnData {
    // 구성에 필요한 데이터
    // lecture
    /*
     struct UserAssignment: Identifiable, Codable {
     var userId: String
     var vodId: String
     var imageURL: String?
     var description: String?
     var submittedAt: Date?
     }
     struct VOD: Identifiable, Codable {
     var vodId: String
     var vodURL: String
     var title: String?
     var description: String?
     var createdAt: Date?
     */
    
    /// VOD 정보와 여러 개의 UserAssignment를 기반으로,
    /// 비동기적으로 이미지를 다운로드하여 완전한 RepeatLearnData 인스턴스를 생성합니다.
    ///
    /// - Parameters:
    ///   - vod: 원본 VOD 데이터.
    ///   - userAssignments: 해당 VOD에 연결된 사용자의 모든 과제 목록.
    /// - Returns: 생성된 RepeatLearnData 인스턴스.
    /// - Throws: VOD의 URL이 유효하지 않을 경우 에러를 던집니다.
    static func generate(from vod: VOD, userAssignments: [UserAssignment]) async throws -> RepeatLearnData {
        
        // 1. VOD의 URL이 유효한지 먼저 확인합니다. 실패하면 함수를 즉시 종료합니다.
        guard let lectureURL = URL(string: vod.vodURL) else {
            print("Error: VOD의 URL이 유효하지 않습니다 - \(vod.vodURL)")
            throw URLError(.badURL)
        }
        
        // 2. 여러 UserAssignment의 이미지를 병렬로 다운로드하고 Assignment로 변환합니다.
        let assignments: [Assignment] = await withTaskGroup(of: Assignment?.self) { group in
            
            for userAssignment in userAssignments {
                // 각 userAssignment에 대해 비동기 변환 작업을 그룹에 추가합니다.
                group.addTask {
                    // Assignment.toAssignment는 인스턴스 메서드가 아니므로,
                    // Assignment 인스턴스를 만들고 호출하는 대신 static 함수로 만들거나,
                    // UserAssignment의 확장으로 만드는 것이 더 좋습니다. (아래 수정안 참고)
                    // 여기서는 일단 주어진 구조를 최대한 활용하겠습니다.
                    let tempAssignment = Assignment(memo: "", image: UIImage(), date: Date())
                    return try? await tempAssignment.convertToAssignment(with: userAssignment)
                }
            }
            
            var convertedAssignments: [Assignment] = []
            // 그룹 내 모든 작업의 결과를 비동기적으로 수집합니다.
            for await assignment in group {
                if let validAssignment = assignment {
                    convertedAssignments.append(validAssignment)
                }
            }
            // 수집된 배열을 반환합니다.
            return convertedAssignments
        }
        
        // 3. 모든 데이터가 준비되면 최종 RepeatLearnData를 생성하여 반환합니다.
        // weeklyProgress와 같은 값은 외부에서 가져오거나 기본값을 사용해야 합니다.
        // 여기서는 예시로 0을 사용합니다.
        let newRepeatLearnData = RepeatLearnData(
            lectureTitle: vod.title ?? "제목 없음",
            lectureDescription: vod.description ?? "설명 없음",
            lectureURL: lectureURL,
            weeklyProgress: 0, // 이 값은 별도의 로직으로 결정해야 합니다.
            assignments: assignments.sorted(by: { $0.date > $1.date }), // 예: 최신순 정렬
            dailyAssignmentChecked: false // 이 값도 별도의 로직으로 결정해야 합니다.
        )
        
        return newRepeatLearnData
    }
}
