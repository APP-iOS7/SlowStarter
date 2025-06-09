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
    
    private var viewModel = LectureListViewModel()
    
    private var lectureExpansionStates: [Bool] = []
    // 각 강의의 확장 상태를 저장할 배열 추가
    
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
    
    private lazy var searchButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(LectureCardCell.self, forCellReuseIdentifier: LectureCardCell.identifier)
        tableView.separatorStyle = .none
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
        view.addSubview(searchButton)
        view.addSubview(locationLabel)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            topStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            searchButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            searchButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            searchButton.widthAnchor.constraint(equalToConstant: 30),
            searchButton.heightAnchor.constraint(equalTo: searchButton.widthAnchor),
            
            locationLabel.centerYAnchor.constraint(equalTo: subtitleLabel.centerYAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
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
        let isExpanded = lectureExpansionStates[indexPath.row]
        cell.configure(with: lecture, isExpanded: isExpanded)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LectureListViewController {
    func didTapThumb(in cell: LectureCardCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let lectureId = viewModel.lectures[indexPath.row].lectureId
        
        // 엄지척 카운트 증가 및 업데이트
        if viewModel.incrementThumbCount(for: lectureId) != nil {
            // 해당 셀만 업데이트
            if let updatedLecture = viewModel.lectures.first(where: { $0.lectureId == lectureId }) {
                cell.configure(with: updatedLecture, isExpanded: lectureExpansionStates[indexPath.row])
            }
        }
    }
    
    func didTapShowDetail(in cell: LectureCardCell) {
        coordinator?.showLectureDetail()
    }
}

#Preview {
    LectureListViewController()
}
