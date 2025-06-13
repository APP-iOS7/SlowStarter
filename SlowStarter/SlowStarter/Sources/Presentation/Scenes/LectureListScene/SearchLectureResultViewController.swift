//
//  SearchLectureResultViewController.swift
//  SlowStarter
//
//  Created by 멘태 on 6/13/25.
//

import UIKit

final class SearchLectureResultViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: LectureCoordinator?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(LectureCardCell.self, forCellReuseIdentifier: LectureCardCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var emptyView: UIView = {
        let view: UIView = UIView()
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyImageView: UIImageView = {
        let iv: UIImageView = UIImageView()
        iv.image = UIImage(systemName: "xmark.circle")
        iv.tintColor = UIColor(named: "MainColor")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let emptyLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "검색 결과가 없습니다."
        label.textColor = .lightGray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = .black
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var filteredLectures: [LectureDetail] = []
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setConstraints()
    }
    
    // MARK: - Funtions
    private func setConstraints() {
        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            emptyView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor),
            
            emptyImageView.topAnchor.constraint(equalTo: emptyView.topAnchor),
            emptyImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 100),
            emptyImageView.heightAnchor.constraint(equalToConstant: 100),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 10),
            emptyLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor),
            emptyLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor)
        ])
    }
    
    func startSearch() {
        filteredLectures.removeAll()
        tableView.reloadData()
        activityIndicator.startAnimating()
    }
    
    func updateResults(with lectures: [LectureDetail], isSearching: Bool = false) {
        filteredLectures = lectures
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.activityIndicator.stopAnimating()
            self?.emptyView.isHidden = !(lectures.isEmpty && !isSearching) // lectures가 비어있고 검색중이 아닐때 노출
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SearchLectureResultViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLectures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LectureCardCell.identifier, for: indexPath) as? LectureCardCell else {
            return UITableViewCell()
        }
        
        // cell.delegate = self
        cell.detail = filteredLectures[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchLectureResultViewController: LectureCardCellDelegate {
    func didTapShowDetail(lectureDetail: LectureDetail) {
        coordinator?.showLectureDetail(lectureDetail)
    }
}
