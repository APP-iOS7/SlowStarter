//
//  ViewController.swift
//  SlowStarter
//
//  Created by sean on 5/22/25.
//

import UIKit

class LectureListViewController: UIViewController, LectureCardCellDelegate {
    
    weak var coordinator: LectureCoordinator?
    // 코디네이터 주입을 위한 프로퍼티 추가
    
    private let viewModel = LectureListViewModel()
    
    // 각 강의의 확장 상태를 저장할 배열 추가
    private var lectureExpansionStates: [Bool] = []
    
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
    
    private let searchBar: UISearchBar = {
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
        tableView.register(LectureCardCell.self, forCellReuseIdentifier: LectureCardCell.identifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 580
        //        tableView.showsVerticalScrollIndicator = true // 스크롤 인디케이터 표시
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // 강의 개수만큼 확장 상태 배열 초기화
        lectureExpansionStates = Array(repeating: false, count: viewModel.lectures.count)
        
        setupUI()
        setupConstraints()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setupUI() {
        view.addSubview(topStackView)
        view.addSubview(searchBar)
        view.addSubview(locationLabel)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        cell.delegate = self
        let lecture = viewModel.lectures[indexPath.row]
        let isExpanded = lectureExpansionStates[indexPath.row] // 해당 셀의 확장 상태 가져오기
        cell.configure(with: lecture, isExpanded: isExpanded) // 확장 상태를 전달
        cell.selectionStyle = .none // 셀 선택 시 회색 하이라이트 제거
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        coordinator?.showLectureDetail() // 코디네이터에게 화면 전환 요청
    }
}

extension LectureListViewController {
    func didTapReadMoreButton(in cell: LectureCardCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            // 해당 셀의 확장 상태 토글
            lectureExpansionStates[indexPath.row].toggle()
            
            // 테이블 뷰에 해당 셀의 높이가 변경되었음을 알림
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}

#Preview {
    LectureListViewController()
}
