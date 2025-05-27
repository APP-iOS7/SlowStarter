//
//  RepeatitiveTableViewCell.swift
//  SlowStarter
//
//  Created by jdios on 5/23/25.
//

import UIKit

class RepeatitiveTableViewCell: UITableViewCell {
    static let identifier = "RepeatitiveTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "여기에 제목이 들어가고 바뀔거임"
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let totalAssignmentLabel: UILabel = {
        let label = UILabel()
        label.text = "+ 0"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let hstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    // MARK: - init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configHstack()
        setupUI()
    }
    
    private func configHstack() {
        let buttonTitles: [String] = ["10P", "20P", "30P"]
        
        for i in 0..<buttonTitles.count {
            let pointButton: UIButton = {
                let button = UIButton(type: .custom)
                button.configuration = .gray()
                button.setTitle(buttonTitles[i], for: .normal)
                button.tintColor = .black
                button.tag = i
                return button
            }()
            
            pointButton.addAction(UIAction(handler: {[weak self] _ in
                self?.pointButtonTapped(tag: pointButton.tag)
            }), for: .touchUpInside)
            
            hstack.addArrangedSubview(pointButton)
        }
        hstack.addArrangedSubview(totalAssignmentLabel)
       
    }
    private func pointButtonTapped(tag: Int) {
        switch tag {
        case 0:
            print("10P")
        case 1:
            print("20P")
        case 2:
            print("30P")
        default:
            break
        }
    }
    
    public func configure() {
        // 강의명 레이블도 조정필요
        // 외부에서 값 조절해야함 특히 토탈어사인먼트 레이블
        
    }
    
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(hstack)
        hstack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


#Preview {
    RepeatitiveTableViewCell()
}
