//
//  LectureCoordinator.swift
//  SlowStarter
//
//  Created by sean on 5/23/25.
//

import UIKit

class LectureCoordinator: Coordinator {
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        // 강의 목록 화면이 시작 화면
        let lectureListViewController = LectureListViewController()
        lectureListViewController.coordinator = self // 코디네이터 주입
        navigationController.pushViewController(lectureListViewController, animated: false)
    }

    // 강의 목록에서 강의 설명을 선택했을 때 호출될 메서드
    func showLectureDetail() {
        let lectureDetailViewController = LectureDetailViewController()
        lectureDetailViewController.coordinator = self // 코디네이터 주입
        navigationController.pushViewController(lectureDetailViewController, animated: false)
    }

    // 강의 설명에서 수강 날짜 선택 버튼을 눌렀을 때 호출될 메서드
    func showLectureDateSelection() {
        let lectureDateViewController = LectureDateViewController()
        lectureDateViewController.coordinator = self // 코디네이터 주입
        navigationController.pushViewController(lectureDateViewController, animated: false)
    }

    // 수강 날짜 선택에서 다음 버튼을 눌렀을 때 호출될 메서드 (모달로 표시)
    func showPayment() {
        let paymentViewController = PaymentViewController()
        
        // 모달 스타일 설정
        paymentViewController.modalPresentationStyle = .pageSheet
        navigationController.present(paymentViewController, animated: false, completion: nil)
    }
}
