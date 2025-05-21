//
//  AssignmentTableViewCell.swift
//  SlowStarter
//
//  Created by jdios on 5/21/25.
//

import UIKit
import SnapKit

class AssignmentTableViewCell: UITableViewCell {
    
    static let identifier = "AssignmentTableViewCell"
    
    private let assignmentImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(systemName: "person.crop.square.on.square.angled.fill")
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private let memoLabel: UILabel = {
        let label = UILabel()
        label.text = "칼질할 때는 손을 오므리고 두번째 마디에 칼 옆면을 대도록 할것"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    private let celltitleLabel: UILabel = {
        let label = UILabel()
        label.text = "번째 인증"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let addPhotoButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.setTitle("사진 추가하기", for: .normal)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
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
    
    private func setupUI() {
        
        contentView.addSubview(celltitleLabel)
        celltitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
        }
        contentView.addSubview(addPhotoButton)
        addPhotoButton.snp.makeConstraints { make in
            make.top.equalTo(celltitleLabel).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            
        }
        contentView.addSubview(assignmentImageView)
        assignmentImageView.snp.makeConstraints { make in
            make.top.equalTo(celltitleLabel.snp.bottom).offset(20)
            make.width.height.equalTo(50)
        }
        contentView.addSubview(memoLabel)
        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(assignmentImageView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(10)
        }
    }
    // 셀에 데이터를 채우는 메서드
    public func configure(with assignment: Assignment) {
        memoLabel.text = assignment.memo
        assignmentImageView.image = assignment.image
    }
    
    // 셀이 재사용될 때 호출되어 이전 데이터를 초기화 (선택적)
    override func prepareForReuse() {
        super.prepareForReuse()
        memoLabel.text = nil
        assignmentImageView.image = nil
    }
    
}


#Preview {
    AssignmentTableViewCell()
}
