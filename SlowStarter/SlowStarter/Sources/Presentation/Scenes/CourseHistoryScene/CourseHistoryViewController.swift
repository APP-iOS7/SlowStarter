import UIKit

class CourseHistoryViewController: UIViewController {
    weak var coordinator: CourseHistoryCoordinator?
    
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CourseHistoryTableViewCell.self, forCellReuseIdentifier: "CourseHistoryCell")
        tableView.rowHeight = 60

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - Data Source
extension CourseHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CourseHistoryCell", for: indexPath) as? CourseHistoryTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: "Course #\(indexPath.row + 1)")
        return cell
    }
}

// MARK: - Delegate
extension CourseHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        coordinator?.showDetail()
    }
}


#Preview {
    CourseHistoryViewController()
}
