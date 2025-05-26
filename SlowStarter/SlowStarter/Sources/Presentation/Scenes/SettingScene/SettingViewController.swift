import UIKit

class SettingViewController: UIViewController {
    weak var coordinator: SettingCoordinator?
    
    private let cellHeight: CGFloat = 44
    private let defaultColor = UIColor(hex: "#F2F2F2")
    
    private let sectionName: [String] = ["알림 설정"]
    private let sectionItemName: [[String]] = [["반복학습 알림", "채팅 알림"]]
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: "SettingCell")

        let versionLabel = UILabel()
        versionLabel.text = "ver 0.0.1"
        versionLabel.font = UIFont(name: "Pretendard-Light", size: 10)
        versionLabel.textColor = .black
        versionLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10), 
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: versionLabel.topAnchor, constant: -10),

            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - DataSource
extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionName.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName[section]
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionItemName[section].count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingTableViewCell
        else {
            return UITableViewCell()
        }
        if indexPath.row == 0 {
            cell.isOn = testFunc // 필요에 의해 수정 필요
        } else {
            cell.isOn = testFunc2
        }
        cell.config(text: sectionItemName[indexPath.section][indexPath.row])
        
        cell.backgroundColor = defaultColor
        
        return cell
    }
    // 이 부분은 나중에 삭제할 예정
    func testFunc() {
        print("test for cell 1 function")
    }
    
    func testFunc2() {
        print("test for cell 2 function")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt: IndexPath) -> Bool {
        return false
    }
    
    
}

// MARK: - Delegate
extension SettingViewController: UITableViewDelegate {
    
}

#Preview {
    SettingViewController()
}
