//
//  RepeatitiveTableViewCell.swift
//  SlowStarter
//
//  Created by jdios on 5/23/25.
//

import UIKit
import SnapKit

///
/// 주요 역할
/// 1. 수정
/// 2. 수정 시 이미지뷰 탭을 통해서 이미지피커 및 이미지 촬영 선택지를 제공하고 그것에서 선택된 것을 기존 이미지와 대체
/// 3. 삭제
/// 4. 이러한 변동사항을 뷰컨트롤러에서 인식 후 데이터 적용

class RepeatitiveTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "RepeatitiveTableViewCell"
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 2
        // titleLabel이 hstack보다 먼저 줄어들도록 압축 저항 우선순위를 낮춤
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let totalAssignmentLabel: UILabel = {
        let label = UILabel()
        label.text = "+ 0"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let hstack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillProportionally // 버튼 크기에 따라 비례하여 채움
        stack.spacing = 10
        return stack
    }()
    
    // 버튼들을 저장할 배열 (configure에서 상태를 업데이트하기 위함)
    private var pointButtons: [UIButton] = []
    private let pointButtonTitles = ["10P", "20P", "30P"]

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupPointButtons()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 셀이 재사용되기 전에 이전 데이터를 초기화합니다.
        titleLabel.text = nil
        totalAssignmentLabel.text = "+ 0"
        
        // 모든 버튼을 기본 상태(활성화, 회색)로 되돌립니다.
        for button in pointButtons {
            button.isEnabled = true
            button.configuration = .gray()
        }
    }
    
    // MARK: - Setup
    
    /// 스택뷰에 들어갈 버튼들을 미리 생성합니다. 이 메서드는 init에서 한 번만 호출됩니다.
    private func setupPointButtons() {
        for (index, title) in pointButtonTitles.enumerated() {
            let button = UIButton(type: .custom)
            button.configuration = .gray()
            button.setTitle(title, for: .normal)
            button.tintColor = .black
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
            make.centerY.equalToSuperview()
        }
        
        hstack.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Actions

    private func pointButtonTapped(tag: Int) {
        // TODO: 버튼 탭 시 필요한 로직 구현 (e.g., delegate 호출)
        switch tag {
        case 0:
            print("10P 버튼 탭")
        case 1:
            print("20P 버튼 탭")
        case 2:
            print("30P 버튼 탭")
        default:
            break
        }
    }
    
    // MARK: - Public Methods
    
    public func configure(with data: RepeatLearnData) {
        self.titleLabel.text = data.lectureTitle
        
        // 추가 과제 개수 레이블 업데이트
        let remainingAssignments = data.assignments.count - pointButtons.count
        if remainingAssignments > 0 {
            self.totalAssignmentLabel.text = "+\(remainingAssignments)"
        } else {
            self.totalAssignmentLabel.text = "+0" // 0개일 때는 숨김
            self.totalAssignmentLabel.isHidden = true
        }
        
        // 주차별 진행 상태에 따라 버튼 UI 업데이트
        for i in 0..<pointButtons.count {
            if i < data.weeklyProgress {
                // 완료된 주차의 버튼
                pointButtons[i].isEnabled = false
                var filledConfig = UIButton.Configuration.filled()
                filledConfig.title = pointButtonTitles[i]
                filledConfig.baseBackgroundColor = .systemGreen
                pointButtons[i].configuration = filledConfig
            } else {
                // 아직 완료되지 않은 주차의 버튼
                pointButtons[i].isEnabled = true
                var grayConfig = UIButton.Configuration.gray()
                grayConfig.title = pointButtonTitles[i]
                pointButtons[i].configuration = grayConfig
            }
        }
    }
}

#Preview {
    RepeatitiveTableViewCell()
}
