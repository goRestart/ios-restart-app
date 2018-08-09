import UIKit

public extension UIView {
    
    func addTopBorderWithWidth(_ width: CGFloat, color: UIColor) -> CALayer {
        let actualWidth = width / UIScreen.main.scale;
        let line = CALayer()
        line.frame = CGRect(x: 0, y: 0, width: frame.width, height: actualWidth)
        line.backgroundColor = color.cgColor
        layer.addSublayer(line)
        return line
    }

    func addBottomBorderWithWidth(_ width: CGFloat, color: UIColor) -> CALayer {
        return addBottomBorderWithWidth(width, xPosition: 0, color: color)
    }

    func addBottomBorderWithWidth(_ width: CGFloat, xPosition: CGFloat, color: UIColor) -> CALayer {
        let actualWidth = width / UIScreen.main.scale;
        let line = CALayer()
        line.frame = CGRect(x: xPosition, y: frame.height - actualWidth, width: frame.width-xPosition, height: actualWidth)
        line.backgroundColor = color.cgColor
        layer.addSublayer(line)
        return line
    }

    func addRightBorderWithWidth(_ width: CGFloat, color: UIColor) -> CALayer {
        let actualWidth = width / UIScreen.main.scale;
        let line = CALayer()
        line.frame = CGRect(x: frame.width - actualWidth, y: 0, width: actualWidth, height: frame.height)
        line.backgroundColor = color.cgColor
        layer.addSublayer(line)
        return line
    }
    
    func addLeftBorderWithWidth(_ width: CGFloat, color: UIColor) -> CALayer {
        let actualWidth = width / UIScreen.main.scale;
        let line = CALayer()
        line.frame = CGRect(x: 0, y: 0, width: actualWidth, height: frame.height)
        line.backgroundColor = color.cgColor
        layer.addSublayer(line)
        return line
    }

    @discardableResult
    func addTopViewBorderWith(width: CGFloat, color: UIColor) -> UIView {
        let topSeparator = UIView()
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topSeparator)
        topSeparator.layout(with: self).leading().trailing().top()
        topSeparator.layout().height(width)
        topSeparator.backgroundColor = color
        return topSeparator
    }

    @discardableResult
    func addBottomViewBorderWith(width: CGFloat, color: UIColor, leftMargin: CGFloat = 0, rightMargin: CGFloat = 0) -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        separator.layout(with: self).leading(by: leftMargin).trailing(by: -rightMargin).bottom()
        separator.layout().height(width)
        separator.backgroundColor = color
        return separator
    }
}


// MARK: - Shadows

public extension UIView {
    func applyFloatingButtonShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        layer.shadowOpacity = 0.24
        layer.shadowRadius = 8.0
    }
    
    func applyDefaultShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3
    }

    func applyShadow(withOpacity opacity: Float,
                     radius: CGFloat,
                     color: CGColor? = UIColor.black.cgColor,
                     offset: CGSize = CGSize(width: 0, height: 0)) {
        layer.shadowColor = color
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }
}


// MARK: - Rounded corners

public extension UIView {
    func setRoundedCorners(_ roundingCorners: UIRectCorner, cornerRadius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners,
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
