//
//  LectureDetailViewModel.swift
//  SlowStarter
//
//  Created by sean on 5/15/25.
//

import Foundation

struct LectureDetailViewModel {

    let title: String = "강의명"
    let curriculumShow: String = "커리큘럼 보기"
    let description: String = "(강의설명)\n\n[Web발신]\n너는나를존중해야한다나는발롱도르를5개와수많은개인트로피를들어올렸으며2016유로에서포르투갈을이끌고우승을차지했고동시에A매치역대최다득점자이다또한챔스역대최다득점자이자5번이나우승을차지한레알마드리드의상징이다또한36세의나이에도프리미어리그에서18골을기록하고챔스에서5경기연속골을기록하며내가세계최고임을증명해냈다은혜를모르는맨유보드진과팬들은내가맨유의골칫덩이라며쫓아냈지만내가세계최고이고내가팀보다위대하다는사실은바뀌지않는다내가사우디에간이유는메시에대한자격지심이아니라유럽에서이룰수있는모든것을이뤘기에아시아를정복하기위해간것이지단지돈을위해서간것이아니다"
        
    let name: String = "호날두"
    let job: String = "일러스트"
    let profileImageURL: String = "https://example.com/instructor.jpg"
    
    let selectedButton: Bool = false
    
    
    let tabTitles: [(tabIcon: String, title: String)] = [
        (tabIcon: "list.bullet", title: "강의목록"),
        (tabIcon: "square.and.pencil", title: "반복학습"),
        (tabIcon: "bubble", title: "채팅"),
        (tabIcon: "person.crop.square", title: "마이페이지")
    ]
}
