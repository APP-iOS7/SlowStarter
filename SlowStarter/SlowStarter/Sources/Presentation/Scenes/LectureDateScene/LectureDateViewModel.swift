//
//  MeetingDateViewModel.swift
//  SlowStarter
//
//  Created by sean on 5/15/25.
//

import Foundation

struct LectureDateViewModel {
    
    let title: String = "강의명"
//    let selectedDate: Date
    
    var lectureDates: [String] = [
        "2025년 6월 20일 금요일 오전 10시",
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
        (tabIcon: "list.bullet", title: "강의목록"),
        (tabIcon: "square.and.pencil", title: "반복학습"),
        (tabIcon: "bubble", title: "채팅"),
        (tabIcon: "person.crop.square", title: "마이페이지")
    ]
}
