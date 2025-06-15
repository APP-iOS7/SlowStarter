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
        self.totalAssignmentLabel.text = overFlowAssignmentCount > 0 ? "+\(overFlowAssignmentCount)" : ""
        
        for (index, button) in pointButtons.enumerated() {
            // ✅ 1. 각 상태에 맞는 configuration을 먼저 결정합니다.
            var config = UIButton.Configuration.filled() // .filled 스타일을 기본으로 사용
            config.title = pointButtonTitles[index]
            
            if index == data.weeklyProgress && data.dailyAssignmentChecked {
                // 상태 3: 인증 가능
                config = .tinted() // .borderedProminent() 대신 .tinted()가 더 적합해 보입니다.
                config.baseBackgroundColor = .systemBlue
                button.isEnabled = true
                
            } else if index == data.weeklyProgress {
                // 상태 2: 인증 대기
                config = .tinted()
                config.baseBackgroundColor = .systemBlue
                config.baseForegroundColor = .white
                button.isEnabled = false
                
            } else if index < data.weeklyProgress {
                // --- 상태 1: 인증 완료 ---
                // ✅ 명시적으로 색상 지정
                config.baseBackgroundColor = .darkGray    // 배경: 중간 회색 (완료됨)
                config.baseForegroundColor = .systemGray     // 텍스트: 어두운 회색
                button.isEnabled = false
                
            } else { // index > data.weeklyProgress
                // --- 상태 4: 미도달 (미래 단계) ---
                // ✅ 명시적으로 색상 지정
                config.baseBackgroundColor = .systemBlue    // 배경: 매우 연한 회색 (미래)
                config.baseForegroundColor = .systemGray2    // 텍스트: 연한 회색
                button.isEnabled = false
            }
            
            // ✅ 2. 결정된 configuration에 공통 속성인 title을 설정합니다.
            config.title = pointButtonTitles[index]
            
            // ✅ 3. 최종 configuration을 버튼에 적용합니다.
            button.configuration = config
        }
    }
}
