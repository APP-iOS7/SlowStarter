//
//  ViewController.swift
//  SlowStarter
//
//  Created by sean on 5/22/25.
//

import UIKit

class LectureListViewController: UIViewController {
    weak var coordinator: LectureCoordinator?
    
    weak var coordinator: LectureFlowCoordinator?
    // 코디네이터 주입을 위한 프로퍼티 추가
    
    private let viewModel = LectureListViewModel()
    
    // MARK: - UI Components
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.title
        label.font = UIFont(name: "Pretendard-Black", size: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.subtitle
        label.font = UIFont(name: "Pretendard-Regular", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy private var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "현재위치: \(viewModel.locationText)"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textAlignment = .right
        return label
    }()
    
    lazy private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = ""
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .default
        let searchTextField = searchBar.searchTextField
        searchTextField.backgroundColor = .clear // 배경 투명하게 설정
//        searchTextField.leftView = nil // 기본 검색 아이콘 제거
//        searchTextField.rightView = UIImageView(image: UIImage(systemName: "magnifyingglass")) // 돋보기 아이콘 추가
        searchTextField.rightViewMode = .always
        searchTextField.tintColor = .black
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(LectureCardCell.self, forCellReuseIdentifier: LectureCardCell.identifier) // 사용자 정의 셀 등록
        tableView.separatorStyle = .none // 셀 구분선 제거
        tableView.showsVerticalScrollIndicator = true // 스크롤 인디케이터 표시
        return tableView
    }()
    
    private let tabBar: UITabBar = {
        let tabBar = UITabBar()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.tintColor = .systemGreen // 활성 탭 색상
        tabBar.unselectedItemTintColor = .systemGray // 비활성 탭 색상
        tabBar.backgroundColor = .white // 탭 바 배경색
        return tabBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground // 뷰의 배경색 설정
        
        setupUI()
        setupConstraints()
        tableView.delegate = self
        tableView.dataSource = self
        tabBar.delegate = self
        setupTabBarItems()
        
        // 내비게이션 바 숨김 해제
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setupUI() {
        view.addSubview(topStackView)
        view.addSubview(searchBar)
        view.addSubview(locationLabel)
        view.addSubview(tableView)
        view.addSubview(tabBar)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 상단 스택 뷰 (제목 및 부제목)
            topStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), // 상단 앵커 조정
            topStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            topStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            searchBar.topAnchor.constraint(equalTo: topStackView.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 350),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            searchBar.heightAnchor.constraint(equalToConstant: 26),
            
            locationLabel.bottomAnchor.constraint(equalTo: topStackView.bottomAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: topStackView.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setupTabBarItems() {
        var items: [UITabBarItem] = []
        for (index, tabData) in viewModel.tabTitles.enumerated() {
            let image = UIImage(named: tabData.tabIcon)
            let item = UITabBarItem(title: tabData.title, image: image, tag: index)
            items.append(item)
        }
        tabBar.setItems(items, animated: false)
        tabBar.selectedItem = tabBar.items?.first // 기본적으로 첫 번째 항목 선택
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension LectureListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.lectures.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LectureCardCell.identifier, for: indexPath) as? LectureCardCell else {
            return UITableViewCell()
        }
        let lecture = viewModel.lectures[indexPath.row]
        cell.configure(with: lecture) // 사용자 정의 셀 구성
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 580 // 카드에 대한 대략적인 높이
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        coordinator?.showLectureDetail() // 코디네이터에게 화면 전환 요청
    }
}
// MARK: - UITabBarDelegate
extension LectureListViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let title = item.title else {
            return print("Selected tab: No title")
        }
        print("Selected tab: \(title)")
    }
}

#Preview {
    LectureListViewController()
}
