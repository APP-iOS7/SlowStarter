import UIKit

class SettingTableViewCell: UITableViewCell {
    
    var isOn: (() -> Void)?
    var isOff: (() -> Void)?
    
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        titleLabel.font = UIFont(name: "Pretendard-Bold", size: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let toggleSwitch = UISwitch()
        toggleSwitch.addAction(UIAction { _ in
            if toggleSwitch.isOn {
                (self.isOn ?? self.testFunc)()
            } else {
                (self.isOff ?? self.testFunc)()
            }
            
        }, for: .valueChanged)
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalStackView = UIStackView(arrangedSubviews: [titleLabel, toggleSwitch])
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .equalSpacing
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(horizontalStackView)
        
        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            horizontalStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            horizontalStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            
        ])
        
    }
    
    func testFunc() {
        print("did not inserted function")
    }
    
    func config(text: String) {
        titleLabel.text = text
    }
}
