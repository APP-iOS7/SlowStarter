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
    
    // ✅ 서버와 통신을 위한 고유 ID들 추가
    var vodId: String
    var lectureTitle: String
    var lectureDescription: String
    var lectureURL: URL
    var weeklyProgress: Int
    var assignments: [Assignment]
    var dailyAssignmentChecked: Bool = false //
}

extension RepeatLearnData {
    // ✅ (개선) VOD와 UserAssignment 목록으로 UI 모델 생성
    static func generate(from vod: VOD, userAssignments: [UserAssignment]) async throws -> RepeatLearnData {
        guard let lectureURL = URL(string: vod.vodURL) else {
            throw URLError(.badURL)
        }
        
        // 여러 과제를 병렬로 변환 (withThrowingTaskGroup 사용)
        let assignments = try await withThrowingTaskGroup(of: Assignment.self, returning: [Assignment].self) { group in
            for ua in userAssignments {
                group.addTask {
                    // ✅ 개선된 정적 메서드 호출
                    return try await Assignment.from(userAssignment: ua)
                }
            }
            
            var converted: [Assignment] = []
            for try await assignment in group {
                converted.append(assignment)
            }
            return converted.sorted(by: >) // 최신순으로 정렬
        }
        
        return RepeatLearnData(
            vodId: vod.vodId,         // ✅ ID 주입
            lectureTitle: vod.title ?? "제목 없음",
            lectureDescription: vod.description ?? "설명 없음",
            lectureURL: lectureURL,
            weeklyProgress: 1, // 이 값은 별도의 로직으로 결정해야 함
            assignments: assignments,
            dailyAssignmentChecked: false
        )

    }
}
