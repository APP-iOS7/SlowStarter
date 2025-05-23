//
//  MeetingDateViewController.swift
//  SlowStarter
//
//  Created by sean on 5/15/25.
//

import UIKit

class LectureDateViewController: UIViewController {
    
    weak var coordinator: LectureCoordinator?
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
        label.text = "강의를 수강할 날짜를 선택해주세요.(총 2개)"
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
        label.text = "2025년 6월 25일\n수요일 오후 2시"
        label.font = UIFont(name: "Pretendard-Black", size: 24)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Black", size: 24)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tabBar: UITabBar = {
        let tabBar = UITabBar()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        tableView.delegate = self
        tableView.dataSource = self
        tabBar.delegate = self
        
        setupTabBarItems()
        
        // 버튼 액션 추가
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(tableView)
        view.addSubview(selectedDateView)
        selectedDateView.addSubview(selectedDateLabel)
        view.addSubview(nextButton)
        view.addSubview(tabBar)
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
            tableView.heightAnchor.constraint(equalToConstant: 250),
            
            selectedDateView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            selectedDateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectedDateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectedDateView.heightAnchor.constraint(equalToConstant: 100),
            
            selectedDateLabel.centerXAnchor.constraint(equalTo: selectedDateView.centerXAnchor),
            selectedDateLabel.centerYAnchor.constraint(equalTo: selectedDateView.centerYAnchor),
            
            nextButton.topAnchor.constraint(equalTo: selectedDateView.bottomAnchor, constant: 20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            nextButton.heightAnchor.constraint(equalToConstant: 60),
            
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setupTabBarItems() {
        var items: [UITabBarItem] = []
        for (index, tabData) in viewModel.tabTitles.enumerated() {
            let image = UIImage(systemName: tabData.tabIcon)
            let item = UITabBarItem(title: tabData.title, image: image, tag: index)
            items.append(item)
        }
        tabBar.setItems(items, animated: false)
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
        return cell
    }
}

// MARK: - UITabBarDelegate
extension LectureDateViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let title = item.title else {
            return print("Selected tab: No title")
        }
        print("Selected tab: \(title)")
    }
}

#Preview {
    LectureDateViewController()
}
