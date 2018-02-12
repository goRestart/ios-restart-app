import Foundation
import UIKit

class UIRoundedLabelWithPadding: UILabel {
    var padding: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = rect.height/2
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += padding.left + padding.right
        size.height += padding.top + padding.bottom
        return size
    }
}
