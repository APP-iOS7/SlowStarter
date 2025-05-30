import UIKit

class CustomDatePicker: UIViewController, UIPickerViewDelegate {
    var onYearMonthSelected: ((Int, Int) -> Void)?
    
    private let pickerView = UIPickerView()
    private var years = Array(2025...2080)
    private let months = Array(1...12)
    
    private var currentYear: Int
    private var currentMonth: Int
    
    init(year initialYear: Int, month initialMonth: Int) {
        self.currentYear = initialYear
        self.currentMonth = initialMonth
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let yearIndex = years.firstIndex(of: currentYear) {
            pickerView.selectRow(yearIndex, inComponent: 0, animated: false)
        }
        pickerView.selectRow(currentMonth - 1, inComponent: 1, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPickerView()
        setupButtons()
    }
    
    private func setupPickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)
        
        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupButtons() {
        let selectedButtonAction = UIAction() {[weak self] _ in
            self?.selectTapped()
        }
        
        let selectButton = UIButton(type: .system)
        selectButton.setTitle("설정하기!", for: .normal)
        selectButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        selectButton.addAction(selectedButtonAction, for: .touchUpInside)
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(selectButton)
        NSLayoutConstraint.activate([
            selectButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
            selectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func selectTapped() {
        let selectedYear = years[pickerView.selectedRow(inComponent: 0)]
        let selectedMonth = months[pickerView.selectedRow(inComponent: 1)]
        onYearMonthSelected?(selectedYear, selectedMonth)
        currentYear = selectedYear
        currentMonth = selectedMonth
        dismiss(animated: true, completion: nil)
    }
}



//MARK: - DataSource
extension CustomDatePicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? years.count : months.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = component == 0 ? .center : .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = component == 0 ? "\(years[row])년" : "\(months[row])월"
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let totalWidth = pickerView.bounds.width
        switch component {
        case 0: return totalWidth * 0.5
        case 1: return totalWidth * 0.5
        default: return 0
        }
    }
}

