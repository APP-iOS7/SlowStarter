//
//  RepeatitiveStudyDetailViewModel.swift
//  SlowStarter
//
//  Created by jdios on 5/23/25.
//

import Foundation
import UIKit

struct RepeatLearnData {
    static let sample = RepeatLearnData(lectureTitle: "예시 강의명",
                                        lectureDescription: "기타 정보 / 기타 정보 / 기타 정보 / 영상길이",
                                        lectureURL: bigbunny,
                                        weeklyProgress: 1,
                                        assignments: Assignment.sampleAssignments)
    
    let lectureTitle: String
    let lectureDescription: String
    let lectureURL: URL
    let weeklyProgress: Int
    var assignments: [Assignment]
    
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
