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
    var onDataUpdated: (([Assignment]) -> Void)?
    
    private var assignments: [Assignment] = Assignment.sampleAssignments.sorted(by: {$0 > $1})
    
    private var indexPathForImageChange: IndexPath?
    
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
        
        // ✅ 버튼에 액션 연결
        uploadButton.addAction(UIAction { [weak self] _ in
            self?.addNewAssignment()
        }, for: .touchUpInside)
    }
    
    // ✅ 2. 뷰가 사라지기 직전에 콜백을 호출하여 변경된 데이터를 전달
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            // 현재 assignments 배열의 상태를 콜백을 통해 전달
            onDataUpdated?(self.assignments)
        }
    
    // 과제 인증 버튼 터치시 작동
    @objc private func addNewAssignment() {
        // 1. 새로운 과제 데이터 생성
        // 기본 이미지를 설정하고 메모는 비워둡니다.
        let newAssignment = Assignment(
            memo: "", // 사용자가 입력할 수 있도록 비워둠
            image: UIImage(systemName: "photo.on.rectangle.angled") ?? UIImage(),
            date: Date()
        )
        
        // 2. 데이터 소스 업데이트 (배열의 맨 앞에 추가)
        assignments.insert(newAssignment, at: 0)
        
        // 3. 테이블 뷰에 새로운 행 삽입
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        // 4. 새로 삽입된 셀을 편집 모드로 전환
        // insertRows가 완료된 후에 셀에 접근하기 위해 약간의 지연을 줍니다.
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: indexPath) as? AssignmentTableViewCell {
                cell.enterEditMode()
            }
        }
    }
    private func openPhotoLibrary() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alert = UIAlertController(title: "오류", message: "카메라를 사용할 수 없습니다", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
//    private func updateImage(_ image: UIImage) {
//        guard let indexPath = indexPathForImageChange else {return}
//        
//        assignments[indexPath.row].image = image
//        tableView.reloadRows(at: [indexPath], with: .fade)
//        self.indexPathForImageChange = nil
//    }
    private func updateImage(_ image: UIImage) {
        guard let indexPath = indexPathForImageChange else { return }
        
        // 1. 데이터 모델은 여전히 업데이트합니다.
        //    (스크롤 등으로 셀이 화면 밖으로 나갔다 다시 돌아올 때 올바른 이미지를 표시하기 위함)
        assignments[indexPath.row].image = image
        
        // 2. 셀을 리로드하는 대신, 해당 셀에 직접 접근하여 UI를 업데이트합니다.
        if let cell = tableView.cellForRow(at: indexPath) as? AssignmentTableViewCell {
            // 셀의 configure 메서드를 재활용하거나, 이미지 뷰만 직접 업데이트하는 메서드를 만들어도 좋습니다.
            // 여기서는 직접 이미지 뷰에 접근하겠습니다.
            cell.updateImageView(with: image)
        }
        
        // 3. 임시 저장 indexPath 초기화
        self.indexPathForImageChange = nil
    }
    
    // MARK: - Data Management
       public func updateData(with assignments: [Assignment]) {
           // 외부에서 받은 데이터로 내부 데이터 소스를 초기화
           self.assignments = assignments
           // 테이블 뷰가 로드되기 전에 데이터가 설정될 수 있으므로,
           // viewIsLoaded를 확인하여 안전하게 리로드
           if self.isViewLoaded {
               self.tableView.reloadData()
           }
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
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
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
        let numbering = "\(assignments.count - indexPath.row ) 번째 반복 인증"
        
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

// MARK: - PHPickerViewControllerDelegate
extension SubmittedAssignmentViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self, let selectedImage = image as? UIImage else {
                    print(error?.localizedDescription)
                    return
                }
                
                DispatchQueue.main.async {
                    self.updateImage(selectedImage)
                }
            }
        }
    }
}
// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension SubmittedAssignmentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // 편집된 이미지가 있으면 사용하고, 없으면 원본 이미지를 사용합니다.
        guard let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        
        // 피커를 닫고 이미지 업데이트
        picker.dismiss(animated: true) { [weak self] in
            self?.updateImage(selectedImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 사용자가 취소하면 피커만 닫습니다.
        picker.dismiss(animated: true)
    }
}

// MARK: - AssignmentTableViewCellDelegate
extension SubmittedAssignmentViewController: AssignmentTableViewCellDelegate {
    
    func didTapImageView(in cell: AssignmentTableViewCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        self.indexPathForImageChange = indexPath
        
        let alert = UIAlertController(title: "사진 변경", message: nil, preferredStyle: .actionSheet)
        
        let libraryAction = UIAlertAction(title: "앨범에서 선택", style: .default) { [weak self] _ in
            self?.openPhotoLibrary()
        }
        let cameraAction = UIAlertAction(title: "카메라로 촬영", style: .default) { [weak self] _ in
            self?.openCamera()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(libraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
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


//
//
#Preview {
    SubmittedAssignmentViewController()
}
