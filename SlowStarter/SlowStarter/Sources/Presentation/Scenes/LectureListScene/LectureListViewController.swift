//
//  ViewController.swift
//  SlowStarter
//
//  Created by sean on 5/22/25.
//

import UIKit

class LectureListViewController: UIViewController {
    
    weak var coordinator: LectureCoordinator?
    // 코디네이터 주입을 위한 프로퍼티 추가
    
    private let viewModel = LectureListViewModel()
    
    // MARK: - UI Components
    lazy private var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "위치: \(viewModel.locationText)"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Black", size: 24)
        label.textAlignment = .left
        return label
    }()
    
    lazy private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = viewModel.searchBarText
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LectureCell")
        return tableView
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
//        self.navigationController?.navigationBar.isHidden = true
        // 내비게이션 바 숨김 유지 (필요에 따라)
    }
    
    private func setupUI() {
        view.addSubview(locationLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(tabBar)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 43),
            locationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            searchBar.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 30),
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
            let image = UIImage(systemName: tabData.tabIcon)
            let item = UITabBarItem(title: tabData.title, image: image, tag: index)
            items.append(item)
        }
        tabBar.setItems(items, animated: false)
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension LectureListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.lectures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LectureCell", for: indexPath)
        cell.textLabel?.text = viewModel.lectures[indexPath.row].title
        cell.backgroundColor = viewModel.lectureListBackgroundColor
        return cell
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
