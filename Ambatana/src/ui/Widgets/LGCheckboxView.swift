
import UIKit

final class LGCheckboxView: UIView {
    
    enum State {
        case selected, semiSelected, deselected
    }
    
    private struct Layout {
        static let lineWidthMutliplier: CGFloat = 7
        static let gridSize: CGSize = CGSize(width: 8.0, height: 8.0)
        static let strokeColour: UIColor = .white
        static let cornerRadius: CGFloat = 4.0
        static let backgroundLineWidth: CGFloat = 1.0
        static let backgroundStrokeColour: CGColor = UIColor.grayLight.cgColor
        static let backgroundFillColour: CGColor = UIColor.primaryColor.cgColor
    }
    
    private var state: State
    
    private let accessoryLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineCap = kCALineCapRound
        layer.lineJoin = kCALineJoinRound
        layer.strokeColor = Layout.strokeColour.cgColor
        layer.fillColor = UIColor.clear.cgColor
        
        return layer
    }()
    
    private var backgroundStrokeColour: CGColor {
        switch self.state {
        case .selected, .semiSelected:
            return UIColor.clear.cgColor
        case .deselected:
            return Layout.backgroundStrokeColour
        }
    }
    
    private var backgroundFillColour: CGColor {
        switch self.state {
        case .selected, .semiSelected:
            return Layout.backgroundFillColour
        case .deselected:
            return UIColor.white.cgColor
        }
    }
    
    init(withFrame frame: CGRect,
         state: State) {
        self.state = state
        super.init(frame: frame)
        layer.addSublayer(accessoryLayer)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = Layout.cornerRadius
        layer.borderWidth = Layout.backgroundLineWidth
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(withState state: State, animated: Bool = false) {
        self.state = state
        setNeedsDisplay()
        
        if animated {
            performTickAnimation()
        }
    }
    
    private func performTickAnimation() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.5
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        accessoryLayer.add(animation, forKey: "tickAnimation")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateBackground()
        updateAccessoryLayer(forRect: rect)
    }
    
    private func updateBackground() {
        layer.borderColor = backgroundStrokeColour
        layer.backgroundColor = backgroundFillColour
    }
    
    private func updateAccessoryLayer(forRect rect: CGRect) {
        accessoryLayer.lineWidth = rect.width/Layout.lineWidthMutliplier
        accessoryLayer.path = accessoryPath(forRect: rect,
                                            state: state)
    }
    
    private func accessoryPath(forRect rect: CGRect,
                               state: State) -> CGPath {
        let unit = CGSize(width: rect.width/Layout.gridSize.width,
                          height: rect.height/Layout.gridSize.height)
        let path = CGMutablePath()
        
        switch state {
        case .selected:
            path.move(to: CGPoint(x: unit.width*2, y: unit.height*4.5))
            path.addLine(to: CGPoint(x: unit.width*3.5, y: unit.height*5.75))
            path.addLine(to: CGPoint(x: unit.width*5.5, y: unit.height*2.5))
            return path
        case .semiSelected:
            path.move(to: CGPoint(x: unit.width*1.5, y: unit.height*4))
            path.addLine(to: CGPoint(x: unit.width*6.5, y: unit.height*4))
            return path
        case .deselected:
            return path
        }
    }
}
