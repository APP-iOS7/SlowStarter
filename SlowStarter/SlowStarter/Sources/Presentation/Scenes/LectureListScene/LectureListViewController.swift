import UIKit

class LectureListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        for family in UIFont.familyNames {
//            print("📁 Font family: \(family)")
//            for name in UIFont.fontNames(forFamilyName: family) {
//                print("  🔤 Font name: \(name)")
//            }
//        }

        // 첫 번째 라벨 (커스텀 폰트 적용)
        let label = UILabel()
        label.text = "커스텀 폰트 적용 완료!"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Black", size: 24) // ⚠️ 폰트 이름 정확히 확인 필요
        view.addSubview(label)

        // 두 번째 라벨 (기본 폰트)
        let label_2 = UILabel()
        label_2.text = "커스텀 적용되지 않은 라벨"
        label_2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label_2)

        // Auto Layout
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            label_2.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            label_2.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

#Preview {
    LectureListViewController()
}
