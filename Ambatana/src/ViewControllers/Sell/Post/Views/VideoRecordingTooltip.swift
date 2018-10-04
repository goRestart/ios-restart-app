import UIKit
import LGComponents

final class RecordingTooltip: UIView {

    private enum Layout {
        static let bubleInsets: UIEdgeInsets = UIEdgeInsets(top: 7, left: 9, bottom: 7, right: 10)
        static let recordingIconRigtMargin: CGFloat = 6
        static let recordingIconSize: CGSize = CGSize(width: 12, height: 12)
        static let arrowSize: CGSize = CGSize(width: 24, height: 10)
        static let bubbleCornerRadius: CGFloat = 10
    }

    let label: UILabel = UILabel()
    let recordingIcon: RecordingIcon = RecordingIcon()
    private let bubbleLayer: CAShapeLayer = CAShapeLayer()

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
                                                   arrowSize: Layout.arrowSize,
                                                   cornerRadius: Layout.bubbleCornerRadius).cgPath
    }

    override var isHidden: Bool {
        didSet {
            if !isHidden {
                recordingIcon.startAnimating()
            } else {
                recordingIcon.stopAnimating()
            }
        }
    }


    private func setupUI() {
        layer.addSublayer(bubbleLayer)
        bubbleLayer.fillColor = UIColor.Camera.tooltipBubble.cgColor
        bubbleLayer.shadowColor = UIColor.black.cgColor
        bubbleLayer.shadowRadius = 4
        bubbleLayer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleLayer.shadowOpacity = 0.5
        bubbleLayer.path = UIBezierPath.bubblePath(for: bounds.size,
                                                   arrowSize: Layout.arrowSize,
                                                   cornerRadius: Layout.bubbleCornerRadius).cgPath

        recordingIcon.backgroundColor = UIColor.Camera.cameraButton

        addSubviewsForAutoLayout([label, recordingIcon])
    }

    private func setupAccessibilityIds() {

    }

    private func setupLayout() {
        recordingIcon.layout(with: self)
            .leading(by: Layout.bubleInsets.left)
        label.layout(with: self)
            .top(by: Layout.bubleInsets.top)
            .bottom(by: -(Layout.bubleInsets.bottom + Layout.arrowSize.height))
            .trailing(by: -Layout.bubleInsets.right)
        label.layout(with: recordingIcon)
            .leading(to: .trailing , by: Layout.recordingIconRigtMargin)
            .centerY()
    }

    final class RecordingIcon: UIView {

        init() {
            super.init(frame: CGRect(origin: .zero, size: Layout.recordingIconSize))
        }

        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) { fatalError() }

        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = width/2
        }

        override var intrinsicContentSize: CGSize {
            return Layout.recordingIconSize
        }

        func startAnimating() {
            alpha = 1
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.autoreverse, .repeat], animations: { [weak self] in
                self?.alpha = 0
                }, completion: nil)
        }

        func stopAnimating() {
            layer.removeAllAnimations()
            alpha = 1
        }
    }
}
