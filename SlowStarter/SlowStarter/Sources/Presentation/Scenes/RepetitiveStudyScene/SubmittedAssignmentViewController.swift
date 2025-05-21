//
//  SubmittedAssignmentViewController.swift
//  SlowStarter
//
//  Created by jdios on 5/21/25.
//

import UIKit


struct Assignment: Identifiable {
    let id = UUID()
    let memo: String
    let image: UIImage
    
    static let sampleAssignments: [Assignment] = [
        Assignment(memo: "첫 번째 과제: 아이디어 스케치", image: UIImage(systemName: "pencil.and.outline") ?? UIImage()),
        Assignment(memo: "두 번째 과제: 프로토타입 제작", image: UIImage(systemName: "hammer.fill") ?? UIImage()),
        Assignment(memo: "세 번째 과제: 사용자 테스트", image: UIImage(systemName: "person.3.fill") ?? UIImage()),
        Assignment(memo: "네 번째 과제: 디자인 수정", image: UIImage(systemName: "paintbrush.pointed.fill") ?? UIImage()),
        Assignment(memo: "다섯 번째 과제: 최종 발표 준비", image: UIImage(systemName: "speaker.wave.2.fill") ?? UIImage())
    ]
}
class SubmittedAssignmentViewController: UIViewController {
    
    var assignments: [Assignment] = Assignment.sampleAssignments
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
