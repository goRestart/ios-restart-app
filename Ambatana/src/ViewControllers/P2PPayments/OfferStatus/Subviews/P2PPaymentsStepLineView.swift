import UIKit
import LGComponents

final class P2PPaymentsStepLineView: UIView {
    var completePercentage: CGFloat = 1 {
        didSet {
            completePercentage = min(max(0.0, completePercentage), 1.0)
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawDashedLine(in: context, rect: rect)
        drawFullLine(in: context, rect: rect)
    }

    private func drawFullLine(in context: CGContext, rect: CGRect) {
        guard completePercentage > 0 else { return }
        let endingY = round(rect.maxY * completePercentage)
        let p0 = CGPoint(x: rect.midX, y: rect.minY)
        let p1 = CGPoint(x: rect.midX, y: endingY)
        context.move(to: p0)
        context.addLine(to: p1)
        context.setLineWidth(4)
        context.setLineDash(phase: 0, lengths: [])
        if completePercentage < 1 {
            context.setLineCap(.round)
        } else {
            context.setLineCap(.butt)
        }
        UIColor.p2pPaymentsPositive.set()
        context.strokePath()
    }

    private func drawDashedLine(in context: CGContext, rect: CGRect) {
        guard completePercentage < 1 else { return }
        let startingY = round(rect.maxY * completePercentage)
        let p0 = CGPoint(x: rect.midX, y: startingY)
        let p1 = CGPoint(x: rect.midX, y: rect.maxY)
        context.move(to: p0)
        context.addLine(to: p1)
        context.setLineDash(phase: 0, lengths: [8, 4])
        context.setLineWidth(1)
        context.setLineCap(.butt)
        UIColor.grayRegular.set()
        context.strokePath()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 4, height: UIViewNoIntrinsicMetric)
    }
}
