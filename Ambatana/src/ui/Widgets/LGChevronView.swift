
import UIKit

final class LGChevronView: UIView {
    
    enum Position {
        case contracted, expanded
    }
    
    private struct Layout {
        static let gridSize: CGSize = CGSize(width: 8.0, height: 3.0)
        static let lineWidthMutliplier: CGFloat = 6
        static let strokeColour: CGColor = UIColor.blackText.withAlphaComponent(0.2).cgColor
        static let fillColour: CGColor = UIColor.clear.cgColor
        static let chevronInset: CGSize = CGSize(width: 4, height: 4)
    }
    
    private let chevronLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineCap = kCALineCapRound
        layer.lineJoin = kCALineJoinRound
        layer.strokeColor = Layout.strokeColour
        layer.fillColor = Layout.fillColour
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return layer
    }()
    
    private var position: Position
    
    override init(frame: CGRect) {
        self.position = .contracted
        super.init(frame: frame)
        layer.addSublayer(chevronLayer)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePosition(withPosition position: Position) {
        self.position = position
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateChevron(forRect: rect)
    }
    
    private func updateChevron(forRect rect: CGRect) {
        chevronLayer.lineWidth = rect.width/Layout.lineWidthMutliplier
        chevronLayer.path = chevronPath(forRect: rect)
        chevronLayer.bounds = rect
        chevronLayer.position = CGPoint(x: rect.midX, y: rect.midY)
        applyChevronTransformation(forPosition: position)
    }
    
    private func applyChevronTransformation(forPosition position: Position) {
        switch position {
        case .expanded:
            chevronLayer.transform = CATransform3DIdentity
        case .contracted:
            let rotation = radians(forDegrees: -90)
            chevronLayer.transform = CATransform3DRotate(CATransform3DIdentity,
                                                         rotation,
                                                         0,
                                                         0,
                                                         1)
        }
    }
    
    private func chevronPath(forRect rect: CGRect) -> CGPath {
        let unit = CGSize(width: rect.width/Layout.gridSize.width,
                          height: rect.height/Layout.gridSize.height)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: unit.width,
                              y: unit.height))
        path.addLine(to: CGPoint(x: unit.width*4,
                                 y: unit.height*2))
        path.addLine(to: CGPoint(x: unit.width*7,
                                 y: unit.height))
        return path
    }
    
    private func radians(forDegrees degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat.pi / 180
    }
}
