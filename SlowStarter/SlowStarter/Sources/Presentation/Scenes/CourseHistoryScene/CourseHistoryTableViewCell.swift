import UIKit

class CourseHistoryTableViewCell: UITableViewCell {
    
    private let lectureTitleLabel = UILabel()
    private let lectureStatusLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        lectureTitleLabel.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        lectureTitleLabel.textAlignment = .left
        lectureTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        lectureStatusLabel.font = UIFont.systemFont(ofSize: 14)
        lectureStatusLabel.textAlignment = .center
        lectureStatusLabel.layer.cornerRadius = 10
        lectureStatusLabel.clipsToBounds = true
        lectureStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(lectureTitleLabel)
        contentView.addSubview(lectureStatusLabel)
        
        NSLayoutConstraint.activate([
            lectureTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            lectureTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            lectureStatusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            lectureStatusLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            lectureStatusLabel.widthAnchor.constraint(equalToConstant: 70),
            lectureStatusLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with title: String, status: Bool) {
        lectureTitleLabel.text = title
        lectureStatusLabel.text = status ? "수강중" : "수강완료"
        lectureStatusLabel.backgroundColor = status ? UIColor(hex: "#FFC107") : UIColor(hex: "#D3D3D3")
    }
}
