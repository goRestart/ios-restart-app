import UIKit
import LGComponents

final class CardView: UIView {
    
    private let preferredCornerRadius: CGFloat
    
    private let cardLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.green.cgColor
        layer.fillColor = UIColor.white.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 2.0
        return layer
    }()
    
    init(frame: CGRect,
         backgroundColour: UIColor,
         cornerRadius: CGFloat) {
        self.preferredCornerRadius = cornerRadius
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        setupView(withBackgroundColour: backgroundColour)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(withBackgroundColour backgroundColour: UIColor) {
        cardLayer.fillColor = backgroundColour.cgColor
        layer.addSublayer(cardLayer)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        cardLayer.path = UIBezierPath(roundedRect: rect,
                                      cornerRadius: preferredCornerRadius).cgPath
        cardLayer.shadowPath = cardLayer.path
    }
}
