import Foundation

open class LGTextField: UITextField {
    
    @objc public var insetX: CGFloat = 0
    public  var insetY: CGFloat = 0
    public var clearButtonOffset: CGFloat = 0
    public  var showCursor = true {
        didSet {
            if showCursor {
                self.tintColor = UIColor.primaryColor
            }
            else {
                self.tintColor = .clear
            }
        }
    }

    public let clearButtonSide : CGFloat = 19
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }
    
    // placeholder position
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX , dy: insetY)
    }
    
    // text position
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: insetX, y: insetY, width: bounds.width-2*insetX-clearButtonSide/2, height: bounds.height-2*insetY)
    }

    // clear button position
    override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let rect = CGRect(x: bounds.size.width-clearButtonSide-clearButtonOffset , y: bounds.midY-clearButtonSide/2, width: clearButtonSide, height: clearButtonSide)
        return rect
    }
    
    
    private func setupTextField() {
        self.borderStyle = UITextBorderStyle.none
        self.insetX = 16
        self.clearButtonOffset = 12
        self.tintColor = UIColor.primaryColor
    }
}
