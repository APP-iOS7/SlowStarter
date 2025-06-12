//
//  MeetingDateViewController.swift
//  SlowStarter
//
//  Created by sean on 5/15/25.
//

import UIKit

class LectureDateViewController: UIViewController {
    
    weak var coordinator: LectureFlowCoordinator?
    // 코디네이터 주입을 위한 프로퍼티 추가
    
    private let viewModel = LectureDateViewModel()
    
    // MARK: - UI Components
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.title
        label.font = UIFont(name: "Pretendard-Black", size: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "상담예약을 위해 날짜를 선택해주세요."
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LectureDateCell")
        return tableView
    }()
    
    private let selectedDateView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var selectedDateLabel: UILabel = {
        let label = UILabel()
        label.text = "위 리스트 중 하나를\n선택하면 표시됩니다."
        label.font = UIFont(name: "Pretendard-Black", size: 24)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("상담예약날짜를 확정합니다.", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 22)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        tableView.delegate = self
        tableView.dataSource = self

        // 버튼 액션 추가
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        // 내비게이션 바 표시 및 뒤로가기 버튼 활성화 (기본값)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(tableView)
        view.addSubview(selectedDateView)
        selectedDateView.addSubview(selectedDateLabel)
        view.addSubview(nextButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 290),
            
            selectedDateView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            selectedDateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            selectedDateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            selectedDateView.heightAnchor.constraint(equalToConstant: 160),
            
            selectedDateLabel.centerXAnchor.constraint(equalTo: selectedDateView.centerXAnchor),
            selectedDateLabel.centerYAnchor.constraint(equalTo: selectedDateView.centerYAnchor),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            nextButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
        
    // 코디네이터에게 화면 전환 요청
    @objc private func nextButtonTapped() {
        coordinator?.showPayment()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension LectureDateViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.lectureDates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LectureDateCell", for: indexPath)
        cell.textLabel?.text = viewModel.lectureDates[indexPath.row]
        cell.backgroundColor = .systemGray6
        
        // 텍스트 크기를 크게 설정합니다.
        cell.textLabel?.font = UIFont(name: "Pretendard-Medium", size: 20)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 선택된 셀의 텍스트를 가져와 selectedDateLabel에 설정합니다.
        selectedDateLabel.text = viewModel.lectureDates[indexPath.row]
        
        // 선택된 셀의 배경색을 변경
//        tableView.cellForRow(at: indexPath)?.backgroundColor = .black
    }
}
