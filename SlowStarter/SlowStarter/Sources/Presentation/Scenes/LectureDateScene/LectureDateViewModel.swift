//
//  MeetingDateViewModel.swift
//  SlowStarter
//
//  Created by sean on 5/15/25.
//

import Foundation

struct LectureDateViewModel {
    
    let title: String = "메시 선생님과 배우는 쿠킹클래스"
//    let selectedDate: Date
    
    var lectureDates: [String] = [
        "2025년 6월 20일 금요일 오전 10시",
        "2025년 6월 21일 토요일 오후 1시",
        "2025년 6월 22일 일요일 오전 9시",
        "2025년 6월 23일 월요일 오후 3시",
        "2025년 6월 24일 화요일 오전 11시",
        "2025년 6월 25일 수요일 오후 2시",
        "2025년 6월 26일 목요일 오전 8시",
        "2025년 6월 27일 금요일 오후 4시",
        "2025년 6월 28일 토요일 오전 10시",
        "2025년 6월 29일 일요일 오후 5시",
        "2025년 6월 30일 월요일 오전 9시"
    ]
    
    let selectedButton: Bool = false
    
    let tabTitles: [(tabIcon: String, title: String)] = [
        (tabIcon: "tabLectureList", title: "강의목록"),
        (tabIcon: "tabLaptopChromebook", title: "반복학습"),
        (tabIcon: "tabChatBubble", title: "채팅"),
        (tabIcon: "tabMypage", title: "마이페이지")
    ]
}
