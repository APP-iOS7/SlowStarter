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
                                        assignments: Assignment.sampleAssignments)
    let lectureTitle: String
    let lectureDescription: String
    let lectureURL: URL
    var assignments: [Assignment]
    
}
