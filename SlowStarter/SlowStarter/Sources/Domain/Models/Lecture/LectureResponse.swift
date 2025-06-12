//
//  LectureResponse.swift
//  SlowStarter
//
//  Created by 멘태 on 6/11/25.
//

import Foundation

struct LectureResponse {
    let lecture: Lecture
    var lecture_intro_images: [LectureIntroImage]?
    var lecture_intro_videos: [LectureIntroVideo]?
}
