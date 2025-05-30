import UIKit

class PaymentHistoryViewController: UIViewController {
    weak var coordinator: PaymentHistoryCoordinator?
    
    
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurationUI()
        setupUI()
    }
    
    func configurationUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PaymentHistoryTableViewCell.self, forCellReuseIdentifier: "PaymentHistoryCell")
    }

    func setupUI() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }

}


extension PaymentHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentHistoryCell") as? PaymentHistoryTableViewCell else {
            return UITableViewCell()
        }
        
        
        return cell
    }
    
    
}

extension PaymentHistoryViewController: UITableViewDelegate {
    
}


#Preview {
    PaymentHistoryViewController()
}
