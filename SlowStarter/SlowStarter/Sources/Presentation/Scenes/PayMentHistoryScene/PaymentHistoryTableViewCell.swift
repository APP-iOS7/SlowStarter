import UIKit

class PaymentHistoryTableViewCell: UITableViewCell {
    
    private let lectureTitle = UILabel()
    private let dateLabel = UILabel()
    private let amountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        lectureTitle.text = "Lorem Ipsum"
        lectureTitle.textColor = .black
        lectureTitle.textAlignment = .left
        lectureTitle.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        
        dateLabel.text = "12/12/2020"
        dateLabel.font = UIFont(name: "Pretendard-Regular", size: 14)
        dateLabel.textColor = .systemGray3
        dateLabel.textAlignment = .left
    
        amountLabel.text = "$100원 결제"
        amountLabel.textColor = .systemGray3
        amountLabel.textAlignment = .left
        amountLabel.font = UIFont(name: "Pretendard-SemiBold", size: 14)
        
        let horizontalStackView = UIStackView(arrangedSubviews: [dateLabel, amountLabel])
        horizontalStackView.axis = .horizontal
        
        let verticalStackView = UIStackView(arrangedSubviews: [lectureTitle, horizontalStackView])
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .equalSpacing
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            verticalStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            verticalStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            dateLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2)
        ])
        
    }
    
    
    func configur(title: String, date: String, amount: String) {
        lectureTitle.text = title
        dateLabel.text = date
        amountLabel.text = amount
    }
    
}
