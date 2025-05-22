import UIKit

extension UIColor {
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        let redHex   = String(hexFormatted.prefix(2))
        let greenHex = String(hexFormatted.dropFirst(2).prefix(2))
        let blueHex  = String(hexFormatted.dropFirst(4).prefix(2))
        
        guard let red = UInt8(redHex, radix: 16),
                let green = UInt8(greenHex, radix: 16),
                let blue = UInt8(blueHex, radix: 16)
        else { return nil }

        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: alpha)
    }
}
