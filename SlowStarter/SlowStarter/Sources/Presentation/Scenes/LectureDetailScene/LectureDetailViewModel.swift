//
//  LectureDetailViewModel.swift
//  SlowStarter
//
//  Created by sean on 5/15/25.
//

import Foundation

struct LectureDetailViewModel {

    let title: String = "메시 선생님과 배우는 쿠킹클래스"
    let price: String = "KRW 99,000"
    let description: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nisl tincidunt eget nullam non. Quis hendrerit dolor magna eget est lorem ipsum dolor sit. Volutpat odio facilisis mauris sit amet massa. Commodo odio aenean sed adipiscing diam donec adipiscing tristique. Mi eget mauris pharetra et. Non tellus orci ac auctor augue. Elit at imperdiet dui accumsan sit. Ornare arcu dui vivamus arcu felis. Egestas integer eget aliquet nibh praesent. In hac habitasse platea dictumst quisque sagittis purus. Pulvinar elementum integer enim neque volutpat ac.</p><p>Senectus et netus et malesuada. Nunc pulvinar sapien et ligula ullamcorper malesuada proin. Neque convallis a cras semper auctor. Libero id faucibus nisl tincidunt eget. Leo a diam sollicitudin tempor id. A lacus vestibulum sed arcu non odio euismod lacinia. In tellus integer feugiat scelerisque."
        
    let name: String = "호날두"
    let job: String = "일러스트"
    let profileImageURL: String = "https://example.com/instructor.jpg"
    
    let selectedButton: Bool = false
    
    
    let tabTitles: [(tabIcon: String, title: String)] = [
        (tabIcon: "list.clipboard", title: "강의목록"),
        (tabIcon: "play.desktopcomputer", title: "반복학습"),
        (tabIcon: "bubble", title: "채팅"),
        (tabIcon: "rectangle.stack.badge.person.crop", title: "마이페이지")
    ]
}
