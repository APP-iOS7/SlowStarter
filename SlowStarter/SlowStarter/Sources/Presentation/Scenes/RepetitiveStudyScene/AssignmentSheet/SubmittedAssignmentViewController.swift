//
//  SubmittedAssignmentViewController.swift
//  SlowStarter
//
//  Created by jdios on 5/21/25.
//

import UIKit
import PhotosUI
import SnapKit

class SubmittedAssignmentViewController: UIViewController {
    
    // MARK: - Properties
    
    private var assignments: [Assignment] = Assignment.sampleAssignments.sorted(by: {$0 > $1})
    
    private let uploadButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.borderedTinted()
        config.title = "과제 인증하기"
        config.image = UIImage(systemName: "plus")
        config.titlePadding = 8
        config.imagePlacement = .leading
        button.configuration = config
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(AssignmentTableViewCell.self, forCellReuseIdentifier: AssignmentTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150 // A reasonable estimate
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView() // Hide empty separators
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  view.backgroundColor = .secondarySystemBackground
        title = "과제 제출"
        setupUI()
        setupTableView()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
       
        view.addSubview(uploadButton)
        uploadButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.trailing.equalToSuperview().inset(16)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(uploadButton.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    private func uploadBtnTapped() {
        
    }
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Data Management
    
    public func updateData(with assignments: [Assignment]) {
        self.assignments = assignments
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension SubmittedAssignmentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AssignmentTableViewCell.identifier, for: indexPath) as? AssignmentTableViewCell else {
            fatalError("Failed to dequeue AssignmentTableViewCell.")
        }
        
        let assignment = assignments[indexPath.row]
        let numbering = "\(indexPath.row + 1) 번째 반복 인증"
        
        cell.configure(with: assignment, numbering: numbering)
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SubmittedAssignmentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Optional: Handle row selection if needed, but in-place editing makes this less necessary.
    }
}

// MARK: - AssignmentTableViewCellDelegate
extension SubmittedAssignmentViewController: AssignmentTableViewCellDelegate {
    func didTapCellEditButton(in cell: AssignmentTableViewCell) {
        // 여기서 데이터 전달
        print("Delegate ON")
    }
    
    
    func assignmentCellDidToggleEditMode(in cell: AssignmentTableViewCell) {
        // This tells the tableView to recalculate cell heights and animate the change
        // smoothly when the text field appears or disappears.
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func cell(_ cell: AssignmentTableViewCell, didFinishEditingMemo newMemo: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        // Update the data model. The cell has already updated its own UI.
        // No need to call `reloadRows` here, which would disrupt the UI state.
        assignments[indexPath.row].memo = newMemo
        print("Updated memo at row \(indexPath.row) to: '\(newMemo)'")
    }

    func didTapCellDeleteButton(in cell: AssignmentTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let assignmentToDelete = assignments[indexPath.row]

        let alert = UIAlertController(
            title: "과제 삭제",
            message: "'\(assignmentToDelete.memo)' 과제를 정말 삭제하시겠습니까?",
            preferredStyle: .alert
        )

        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // 1. Remove data from the model
            self.assignments.remove(at: indexPath.row)
            
            // 2. Animate the deletion from the table view
            // Note: This causes a visual glitch if your cell numbering is based on `indexPath.row`.
            // For a better experience, you should reload all visible cells or the entire table
            // after the deletion animation completes, or use stable IDs for numbering.
            // For simplicity, we'll just delete the row here.
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}


#Preview {
 SubmittedAssignmentViewController()
}
