import UIKit
import LGComponents

final class RecordingTooltip: UIView {

    let label: UILabel = UILabel()
    let recordingIcon: RecordingIcon = RecordingIcon()
    private let bubbleLayer: CAShapeLayer = CAShapeLayer()
    private let bubbleCornerRadius: CGFloat = 10
    private let arrowSize = CGSize(width: 24, height: 10)

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
        bubbleLayer.fillColor = UIColor(white: 44/255, alpha: 0.95).cgColor
        bubbleLayer.shadowColor = UIColor.black.cgColor
        bubbleLayer.shadowRadius = 4
        bubbleLayer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleLayer.shadowOpacity = 0.5
        bubbleLayer.path = UIBezierPath.bubblePath(for: bounds.size,
                                                   arrowSize: arrowSize,
                                                   cornerRadius: bubbleCornerRadius).cgPath

        recordingIcon.backgroundColor = UIColor.Camera.cameraButton

        addSubviewsForAutoLayout([label, recordingIcon])
    }

    private func setupAccessibilityIds() {

    }

    private func setupLayout() {
        recordingIcon.layout(with: self)
            .leading(by: 9)
        label.layout(with: self)
            .top(by: 7)
            .bottom(by: -(7 + arrowSize.height))
            .trailing(by: -Metrics.shortMargin)
        label.layout(with: recordingIcon)
            .leading(to: .trailing , by: 6)
            .centerY()
    }

    final class RecordingIcon: UIView {
        static let size = CGSize(width: 12, height: 12)

        init() {
            super.init(frame: CGRect(origin: .zero, size: RecordingIcon.size))
        }

        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) { fatalError() }

        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = width/2
        }

        override var intrinsicContentSize: CGSize {
            return RecordingIcon.size
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
