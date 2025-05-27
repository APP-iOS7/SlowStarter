////
////  SubmittedAssignmentViewController.swift
////  SlowStarter
////
////  Created by jdios on 5/21/25.
////
//
//

import UIKit
import SnapKit


class SubmittedAssignmentViewController: UIViewController {
    
    private var assignments: [Assignment] = Assignment.sampleAssignments
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(AssignmentTableViewCell.self, forCellReuseIdentifier: AssignmentTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension // 셀 높이 자동 조절
        tableView.estimatedRowHeight = 100 // 미리 크기 예측
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
// MARK: - UITableViewDelegate
extension SubmittedAssignmentViewController: UITableViewDelegate {
    // (선택) 특정 행을 선택했을 때의 동작
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // 선택 효과 해제
        let selectedAssignment = assignments[indexPath.row]
        print("선택된 과제: \(selectedAssignment.memo)")
        // 여기에 네비게이션 또는 다른 작업 추가 가능
    }
}
extension SubmittedAssignmentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AssignmentTableViewCell.identifier, for: indexPath) as? AssignmentTableViewCell else {
            fatalError("Could not dequeue cell")
        }
        
        let assignment = assignments[indexPath.row]
        let numbering = "\(indexPath.row + 1) 번째 반복 인증"
        cell.configure(with: assignment, numbering: numbering)
        cell.delegate = self
        
        return cell
    }
}

extension SubmittedAssignmentViewController: AssignmentTableViewCellDelegate {
    
    func didTapAssignmentButton(in cell: AssignmentTableViewCell) {
        print("DELEGATE")
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        print("\(indexPath.row)번째 과제 버튼 터치")
        
    }
    
    
}
//
//#Preview {
//    SubmittedAssignmentViewController()
//}
