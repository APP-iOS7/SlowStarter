//
//  AssignmentTableViewCell.swift
//  SlowStarter
//
//  Created by jdios on 5/21/25.
//

import UIKit
import SnapKit

class AssignmentTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: AssignmentTableViewCellDelegate?
    static let identifier = "AssignmentTableViewCell"
    
    private var isEditingCell: Bool = false
    
    // MARK: - UI Components
    
    private let imageBaseView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private let assignmentImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(systemName: "person.crop.square.on.square.angled.fill")
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private let memoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let editTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.isHidden = true // Initially hidden
        return textField
    }()
    
    private let celltitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.setTitle("삭제", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didTapCellDeleteButton(in: self)
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.setTitle("수정", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addAction(UIAction { [weak self] _ in
            self?.toggleEditingState()
        }, for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        editTextField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset cell to its default state before being reused
        isEditingCell = false
        memoLabel.isHidden = false
        editTextField.isHidden = true
        editButton.setTitle("수정", for: .normal)
        deleteButton.isEnabled = true
        
        // Clear content
        memoLabel.text = nil
        editTextField.text = nil
        assignmentImageView.image = nil
        celltitleLabel.text = nil
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        contentView.addSubview(celltitleLabel)
        celltitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(10)
        }
        
        buttonStackView.addArrangedSubview(editButton)
        buttonStackView.addArrangedSubview(deleteButton)
        
        contentView.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.centerY.equalTo(celltitleLabel)
            make.trailing.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(imageBaseView)
        imageBaseView.snp.makeConstraints { make in
            make.top.equalTo(celltitleLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(50)
        }
        
        imageBaseView.addSubview(assignmentImageView)
        assignmentImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(memoLabel)
        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(imageBaseView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(editTextField)
        editTextField.snp.makeConstraints { make in
            // Match the memoLabel's constraints
            make.top.equalTo(memoLabel)
            make.leading.equalTo(memoLabel)
            make.trailing.equalTo(memoLabel)
        }
    }
    
    // MARK: - Public Methods
    
    public func configure(with assignment: Assignment, numbering: String) {
        memoLabel.text = assignment.memo
        assignmentImageView.image = assignment.image
        celltitleLabel.text = numbering
    }
    
    // MARK: - Private Methods

    private func toggleEditingState() {
        isEditingCell.toggle()
        
        if isEditingCell {
            // --- Start Editing ---
            memoLabel.isHidden = true
            editTextField.isHidden = false
            editTextField.text = memoLabel.text
            editTextField.becomeFirstResponder() // Show keyboard
            
            editButton.setTitle("완료", for: .normal)
            deleteButton.isEnabled = false // Disable delete while editing
        } else {
            // --- Finish Editing ---
            memoLabel.isHidden = false
            editTextField.isHidden = true
            memoLabel.text = editTextField.text
            
            editButton.setTitle("수정", for: .normal)
            deleteButton.isEnabled = true
            
            // Inform the delegate that editing has finished with the new text
            delegate?.cell(self, didFinishEditingMemo: editTextField.text ?? "")
        }
        
        // Inform the delegate that the edit mode has toggled, so it can update the table view layout
        // delegate?.assignmentCellDidToggleEditMode(in: self)
    }
}

// MARK: - UITextFieldDelegate
extension AssignmentTableViewCell: UITextFieldDelegate {
    // Allows finishing the edit by pressing the "Done" key on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hide keyboard
        toggleEditingState() // Trigger the "Finish Editing" logic
        return true
    }
}
