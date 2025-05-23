import UIKit

class YearMonthPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var onYearMonthSelected: ((Int, Int) -> Void)?

    private let pickerView = UIPickerView()
    private var years: [Int] = []
    private let months = Array(1...12)

    private let currentYear = Calendar.current.component(.year, from: Date())
    private let currentMonth = Calendar.current.component(.month, from: Date())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupData()
        setupPickerView()
        setupButtons()
    }

    private func setupData() {
        years = Array(2000...2100)
    }

    private func setupPickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)

        // 현재 연도, 월로 초기 선택
        if let yearIndex = years.firstIndex(of: currentYear) {
            pickerView.selectRow(yearIndex, inComponent: 0, animated: false)
        }
        pickerView.selectRow(currentMonth - 1, inComponent: 1, animated: false)

        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupButtons() {
        let selectButton = UIButton(type: .system)
        selectButton.setTitle("선택", for: .normal)
        selectButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        selectButton.addTarget(self, action: #selector(selectTapped), for: .touchUpInside)
        selectButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(selectButton)
        NSLayoutConstraint.activate([
            selectButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
            selectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func selectTapped() {
        let selectedYear = years[pickerView.selectedRow(inComponent: 0)]
        let selectedMonth = months[pickerView.selectedRow(inComponent: 1)]
        onYearMonthSelected?(selectedYear, selectedMonth)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UIPickerViewDataSource & Delegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // 연도 + 월
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? years.count : months.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? "\(years[row])년" : "\(months[row])월"
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return view.bounds.width / 2
    }
}
