import UIKit
import LGComponents
import RxSwift
import RxCocoa

final class CameraTooltip: UIView {

    let label: UILabel = UILabel()
    private let bubbleLayer: CAShapeLayer = CAShapeLayer()
    private let bubbleCornerRadius: CGFloat = 10
    private let arrowSize = CGSize(width: 24, height: 10)

    fileprivate let tapGesture = UITapGestureRecognizer(target: nil, action: nil)

    init() {
        super.init(frame: .zero)

        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleLayer.path = UIBezierPath.bubblePath(for: bounds.size,
                                                   arrowSize: arrowSize,
                                                   cornerRadius: bubbleCornerRadius).cgPath
    }

    private func setupUI() {
        addGestureRecognizer(tapGesture)
        bubbleLayer.fillColor = UIColor(white: 44/255, alpha: 0.95).cgColor
        bubbleLayer.shadowColor = UIColor.black.cgColor
        bubbleLayer.shadowRadius = 4
        bubbleLayer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleLayer.shadowOpacity = 0.5
        bubbleLayer.path = UIBezierPath.bubblePath(for: bounds.size,
                                                   arrowSize: arrowSize,
                                                   cornerRadius: bubbleCornerRadius).cgPath

        layer.addSublayer(bubbleLayer)

        addSubviewForAutoLayout(label)
    }

    private func setupAccessibilityIds() {
        label.set(accessibilityId: .postingCameraTooltipLabel)
    }

    private func setupLayout() {
        label.layout(with: self)
            .top(by: Metrics.margin)
            .left(by: Metrics.bigMargin)
            .bottom(by: -(Metrics.margin + arrowSize.height))
            .right(by: -Metrics.bigMargin)
    }
}

extension Reactive where Base: CameraTooltip {
    var tooltipTapped: ControlEvent<UITapGestureRecognizer> {
        return base.tapGesture.rx.event
    }
}

extension UIBezierPath {
    static func bubblePath(for contentSize: CGSize, arrowSize: CGSize, cornerRadius: CGFloat) -> UIBezierPath {
        let topLeftCorner = CGPoint(x: 0, y: 0)
        let topRightCorner = CGPoint(x: contentSize.width, y: 0)
        let bottomRightCorner = CGPoint(x: contentSize.width, y: contentSize.height - arrowSize.height)
        let bottomLeftCorner = CGPoint(x: 0, y: contentSize.height - arrowSize.height)
        let rigthArrowCorner = CGPoint(x: contentSize.width / 2 + arrowSize.width / 2, y: bottomRightCorner.y)
        let bottomArrowCorner = CGPoint(x: contentSize.width / 2, y: contentSize.height)
        let leftArrowCorner = CGPoint(x: contentSize.width / 2 - arrowSize.width / 2, y: bottomRightCorner.y)

        let arrowBaseCurveControlPointDistance: CGFloat = arrowSize.width / 3
        let arrowTopCurveControlPointDistance: CGFloat = arrowBaseCurveControlPointDistance / 2

        let bezierPath = UIBezierPath()

        // Top left corner
        bezierPath.move(to: CGPoint(x: topLeftCorner.x, y: cornerRadius))
        bezierPath.addQuadCurve(to: CGPoint(x: topLeftCorner.x + cornerRadius, y: topLeftCorner.y),
                                controlPoint: topLeftCorner)
        // Top right corner
        bezierPath.addLine(to: CGPoint(x: topRightCorner.x - cornerRadius, y: topRightCorner.y))
        bezierPath.addQuadCurve(to: CGPoint(x: topRightCorner.x, y: topRightCorner.y + cornerRadius),
                                controlPoint: topRightCorner)
        // Bottom right corner
        bezierPath.addLine(to: CGPoint(x: bottomRightCorner.x, y: bottomRightCorner.y - cornerRadius))
        bezierPath.addQuadCurve(to: CGPoint(x: bottomRightCorner.x - cornerRadius, y: bottomRightCorner.y),
                                controlPoint: bottomRightCorner)
        // Arrow
        bezierPath.addCurve(to: rigthArrowCorner,
                            controlPoint1: bottomRightCorner,
                            controlPoint2: CGPoint(x: rigthArrowCorner.x + arrowBaseCurveControlPointDistance, y: rigthArrowCorner.y))
        bezierPath.addCurve(to: bottomArrowCorner,
                            controlPoint1: CGPoint(x: rigthArrowCorner.x - arrowBaseCurveControlPointDistance, y: rigthArrowCorner.y),
                            controlPoint2: CGPoint(x: bottomArrowCorner.x + arrowTopCurveControlPointDistance, y: bottomArrowCorner.y))
        bezierPath.addCurve(to: leftArrowCorner,
                            controlPoint1: CGPoint(x: bottomArrowCorner.x - arrowTopCurveControlPointDistance, y: bottomArrowCorner.y),
                            controlPoint2: CGPoint(x: leftArrowCorner.x + arrowBaseCurveControlPointDistance, y: leftArrowCorner.y))
        bezierPath.addCurve(to: CGPoint(x: bottomLeftCorner.x + cornerRadius, y: bottomLeftCorner.y),
                            controlPoint1: CGPoint(x: leftArrowCorner.x - arrowBaseCurveControlPointDistance, y: leftArrowCorner.y),
                            controlPoint2: bottomLeftCorner)
        // Bottom left corner
        bezierPath.addQuadCurve(to: CGPoint(x: bottomLeftCorner.x, y: bottomLeftCorner.y - cornerRadius),
                                controlPoint: bottomLeftCorner)
        bezierPath.close()

        return bezierPath
    }
}

extension CGRect {
    static func centeredFrameWithSize(size: CGSize) -> CGRect {
        let origin = CGPoint(x: -(size.width / 2), y: -(size.height / 2))
        return CGRect(origin: origin, size: size)
    }
}
