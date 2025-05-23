//
//  LectureListViewModel.swift
//  SlowStarter
//
//  Created by 고요한 on 5/9/25.
//

import Foundation
import UIKit

struct LectureListViewModel {
    
    let locationText: String = "강남구"
    let searchBarText: String = "사는곳 또는 직무를 입력해 강의를 검색하세요."
    
    var lectures: [Lecture] = [
        Lecture(lectureId: UUID().uuidString, instructorId: UUID().uuidString, title: "기초 일러스트레이터 따라 하기", description: "그림 그리기 초보도 쉽게 배우는 일러스트레이터 기초 과정"),
            Lecture(lectureId: UUID().uuidString, instructorId: UUID().uuidString, title: "향긋한 나만의 커피 만들기 (바리스타 기초)", description: "집에서도 쉽게 따라 할 수 있는 홈 바리스타 기초 과정"),
            Lecture(lectureId: UUID().uuidString, instructorId: UUID().uuidString, title: "매콤달콤 제육볶음 만들기", description: "누구나 좋아하는 제육볶음을 쉽고 맛있게 만드는 비법"),
            Lecture(lectureId: UUID().uuidString, instructorId: UUID().uuidString, title: "간단한 손바느질로 소품 만들기", description: "바늘과 실만으로 뚝딱뚝딱! 나만의 개성 있는 소품 만들기"),
            Lecture(lectureId: UUID().uuidString, instructorId: UUID().uuidString, title: "쉬운 목공예, 연필꽂이 만들기", description: "톱과 망치 없이 간단한 도구로 나무 연필꽂이 만들기"),
            Lecture(lectureId: UUID().uuidString, instructorId: UUID().uuidString, title: "기초 사진 촬영 따라 하기", description: "스마트폰 카메라로 멋진 사진 찍는 방법 배우기"),
            Lecture(lectureId: UUID().uuidString, instructorId: UUID().uuidString, title: "신나는 텃밭 가꾸기", description: "씨앗부터 수확까지! 직접 키우는 즐거움 배우기"),
            Lecture(lectureId: UUID().uuidString, instructorId: UUID().uuidString, title: "즐거운 종이접기 교실", description: "손으로 조물조물! 재미있는 종이접기의 세계"),
            Lecture(lectureId: UUID().uuidString, instructorId: UUID().uuidString, title: "나만의 액세서리 만들기", description: "개성을 뽐낼 수 있는 특별한 액세서리를 직접 만들어 보세요"),
            Lecture(lectureId: UUID().uuidString, instructorId: UUID().uuidString, title: "간단한 정리 수납 전문가 되기", description: "주변을 깔끔하게 정리하는 노하우 배우기")
    ]
    
    let tabTitles: [(tabIcon: String, title: String)] = [
        (tabIcon: "list.bullet", title: "강의목록"),
        (tabIcon: "square.and.pencil", title: "반복학습"),
        (tabIcon: "bubble", title: "채팅"),
        (tabIcon: "person.crop.square", title: "마이페이지")
    ]
    
    // MARK: - UI Style
    let lectureListBackgroundColor: UIColor = .systemGray6
}
