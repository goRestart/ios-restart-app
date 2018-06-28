import UIKit

public extension UIView {
    func setRoundedCorners() {
        clipsToBounds = true
        layer.cornerRadius =  min(bounds.size.height, bounds.size.width) / 2.0
    }

    var cornerRadius: CGFloat {
        set {
            clipsToBounds = true
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
}
