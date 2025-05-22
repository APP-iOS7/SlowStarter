//
//  LectureDetailViewModel.swift
//  SlowStarter
//
//  Created by sean on 5/15/25.
//

import Foundation

struct LectureDetailViewModel {

    let title: String = ""
    
    let tabTitles: [(tabIcon: String, title: String)] = [
        (tabIcon: "list.bullet", title: "강의목록"),
        (tabIcon: "square.and.pencil", title: "반복학습"),
        (tabIcon: "bubble", title: "채팅"),
        (tabIcon: "person.crop.square", title: "마이페이지")
    ]
}
