//  RepeatitiveTableViewCell.swift

import UIKit
import SnapKit

class RepeatitiveTableViewCell: UITableViewCell {
    
    weak var delegate: RepeatitiveTableViewCellDelegate?
    static let identifier = "RepeatitiveTableViewCell"
    
    // --- UI Components (변경 없음) ---
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let totalAssignmentLabel: UILabel = {
        let label = UILabel()
        label.text = "+0"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let hstack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.spacing = 10
        return stack
    }()
    
    private var pointButtons: [UIButton] = []
    private let pointButtonTitles = ["10P", "20P", "30P"]
    
    // --- Initializers (변경 없음) ---
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupPointButtons()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // --- Setup (변경 없음) ---
    private func setupPointButtons() {
        for (index, title) in pointButtonTitles.enumerated() {
            let button = UIButton(type: .custom)
            button.tag = index
            button.addAction(UIAction { [weak self] _ in
                self?.pointButtonTapped(tag: button.tag)
            }, for: .touchUpInside)
            
            pointButtons.append(button)
            hstack.addArrangedSubview(button)
        }
        hstack.addArrangedSubview(totalAssignmentLabel)
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(hstack)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(12) // 적절한 상단 여백
            make.bottom.equalToSuperview().inset(12) // 적절한 하단 여백
        }
        
        hstack.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    // --- Actions ---
    private func pointButtonTapped(tag: Int) {
        // 셀은 더 이상 UI를 직접 바꾸지 않고, Delegate에게 보고만 합니다.
        delegate?.repeatitiveCell(self, didTapPointButtonAtIndex: tag)
    }
    
    // --- Public Methods ---
    public func configure(with data: RepeatLearnData) {
        self.titleLabel.text = data.lectureTitle
        
        let overFlowAssignmentCount = data.assignments.count - 3
        if overFlowAssignmentCount >= 0 {
            self.totalAssignmentLabel.text = "+\(overFlowAssignmentCount)"
        } else {
            self.totalAssignmentLabel.text = "+0"
        }
        
        
        // [요청사항 1] 3단계 버튼 비주얼 로직 적용
        for (index, button) in pointButtons.enumerated() {
            var config = UIButton.Configuration.gray() // 기본은 회색
            config.title = pointButtonTitles[index]
            
            if index < data.weeklyProgress {
                // --- 상태 1: 인증 완료 ---
                // 회색 버튼, 비활성화
                config.title = pointButtonTitles[index]
                config.baseBackgroundColor = .darkGray
                config.baseForegroundColor = .white
                button.configuration = config
                
                button.isEnabled = false
                
            } else if index == data.weeklyProgress {
                // --- 상태 2: 인증 대기 (다음 차례) ---
                // 파란색 테두리 버튼, 비활성화
                config = .tinted()
                config.title = pointButtonTitles[index]
                button.configuration = config
                button.isEnabled = false
                
            } else if  index == data.weeklyProgress && data.dailyAssignmentChecked {
                // --- 상태 4: 아직 인증되지 않은 미래 단계 ---
                // 회색 테두리 버튼, 비활성화
                config = .borderedProminent()
                config.title = pointButtonTitles[index]
                button.configuration = config
                button.isEnabled = true
                
            } else {
                // --- 상태 4: 아직 인증되지 않은 미래 단계 ---
                // 회색 테두리 버튼, 비활성화
                config = .gray()
                config.title = pointButtonTitles[index]
                button.configuration = config
                button.isEnabled = false
            }
        }
    }
}
