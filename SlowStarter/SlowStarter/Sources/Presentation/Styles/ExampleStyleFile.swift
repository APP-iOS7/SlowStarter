import UIKit


//MARK: - 예시
extension UIColor {
    static let Primary: UIColor = .systemBlue
    static let Secondary: UIColor = .systemGray
}

extension UIFont {
    static let Title: UIFont = .systemFont(ofSize: 32, weight: .bold)
}

extension UIEdgeInsets {
    static let zero: UIEdgeInsets = .zero
    static let mainPadding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
}

extension UIButton {
    static let primary: UIButton = {
        let button = UIButton(type: .system)
        //기타 스타일 적용
        return button
    }()
}

//컴포넌트끼리 파일을 나누어도 되고 필요에 의해 적용하면 됨.
