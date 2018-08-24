
import UIKit

final class ExtraInfoTagView: UILabel {
        
    private enum UI {
        static let font = UIFont.boldSystemFont(ofSize: 13.0)
        static let insets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        static let backgroundFillColour = UIColor.black.withAlphaComponent(0.3)
        static let backgroundStrokeColour = UIColor.white.withAlphaComponent(0.48)
        static let backgroundLineWidth: CGFloat = 2.0
    }
    
    private let primaryColour: UIColor
    
    init(withColour colour: UIColor) {
        self.primaryColour = colour
        super.init(frame: .zero)
        performInitialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func performInitialSetup() {
        textColor = primaryColour
        textAlignment = .center
        font = UI.font
    }
    
    override func drawText(in rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        drawBackground(in: rect, withContext: ctx)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, UI.insets))
    }
    
    private func drawBackground(in rect: CGRect,
                                withContext ctx: CGContext) {
        let rect = rect.insetBy(dx: UI.backgroundLineWidth, dy: UI.backgroundLineWidth)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height/2)
        
        ctx.setStrokeColor(UI.backgroundStrokeColour.cgColor)
        ctx.setLineWidth(UI.backgroundLineWidth)
        ctx.addPath(path.cgPath)
        ctx.strokePath()
        
        ctx.setFillColor(UI.backgroundFillColour.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
    }

    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        return CGSize(width: superSize.width + UI.insets.left + UI.insets.right,
                      height: superSize.height + UI.insets.top + UI.insets.bottom)
    }
}
