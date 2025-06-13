//
//  SearchLectureResultViewController.swift
//  SlowStarter
//
//  Created by 멘태 on 6/13/25.
//

import UIKit

final class SearchLectureResultViewController: UIViewController {
    // MARK: - Properties
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(LectureCardCell.self, forCellReuseIdentifier: LectureCardCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
        indicator.center = self.tableView.center
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.color = UIColor.black
        return indicator
    }()
    
    private var filteredLectures: [LectureDetail] = []
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setConstraints()
    }
    
    // MARK: - Funtions
    private func setConstraints() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }
    
    func startSearch() {
        filteredLectures.removeAll()
        tableView.reloadData()
        activityIndicator.startAnimating()
    }
    
    func updateResults(with lectures: [LectureDetail]) {
        filteredLectures = lectures
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.activityIndicator.stopAnimating()
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
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
