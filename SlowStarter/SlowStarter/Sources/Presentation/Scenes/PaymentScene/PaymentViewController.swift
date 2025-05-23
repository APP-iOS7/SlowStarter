//
//  PaymentViewController.swift
//  SlowStarter
//
//  Created by sean on 5/23/25.
//

import UIKit

class PaymentViewController: UIViewController {
    
    weak var coordinator: LectureCoordinator?
    // 코디네이터 주입을 위한 프로퍼티 추가
    
    private let paymentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("결제완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Black", size: 24)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray5
        setupUI()
        setupConstraints()
        
        paymentButton.addTarget(self, action: #selector(paymentButtonTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(paymentButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            paymentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            paymentButton.widthAnchor.constraint(equalToConstant: 300),
            paymentButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // 코디네이터에게 화면 전환 요청
    @objc private func paymentButtonTapped() {
        coordinator?.start()
    }
}

#Preview {
    PaymentViewController()
}
