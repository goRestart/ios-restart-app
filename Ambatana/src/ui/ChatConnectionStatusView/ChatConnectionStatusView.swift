import UIKit
import LGComponents

final class ChatConnectionStatusView: UIView {
    private struct Layout {
        static let insets = UIEdgeInsets(top: 8, left: 15, bottom: 9, right: 15)
        static let activityIndicatorWidth: CGFloat = 20
    }
    static let standardHeight: CGFloat = 30

    var status: ChatConnectionBarStatus = .wsConnected {
        didSet {
            updateBarFor(status: status)
        }
    }

    private var activityIndicatorWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var activityIndicatorTrailingMarginConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var actionBlock: (()->Void)?
    private var containerView: UIView = UIView()
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont.systemRegularFont(size: 13)
        return label
    }()

    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.transform = CGAffineTransform.init(scaleX: 0.75, y: 0.75)
        return activityIndicator
    }()

    convenience init() {
        self.init(frame: .zero)
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        backgroundColor = UIColor.toastBackground
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(exectuteActionBlock))
        addGestureRecognizer(tapRecognizer)
    }

    @objc private func exectuteActionBlock() {
        actionBlock?()
    }

    private func setupConstraints() {
        addSubviewForAutoLayout(containerView)
        containerView.addSubviewsForAutoLayout([activityIndicator, titleLabel])

        activityIndicatorWidthConstraint = activityIndicator
            .widthAnchor
            .constraint(equalToConstant: Layout.activityIndicatorWidth)
        activityIndicatorTrailingMarginConstraint = titleLabel
            .leadingAnchor
            .constraint(equalTo: activityIndicator.trailingAnchor, constant: Metrics.veryShortMargin)

        NSLayoutConstraint.activate([
            activityIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            activityIndicator.topAnchor.constraint(equalTo: containerView.topAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            activityIndicatorWidthConstraint,
            activityIndicatorTrailingMarginConstraint,
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.insets.top),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Layout.insets.right),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.insets.bottom),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Layout.insets.left)
            ])
    }

    override var intrinsicContentSize : CGSize {
        var size = titleLabel.intrinsicContentSize
        size.height += Layout.insets.top + Layout.insets.bottom
        size.width += Layout.insets.left + Layout.insets.right
        return size
    }

    private func updateBarFor(status: ChatConnectionBarStatus) {
        titleLabel.attributedText = status.title
        activityIndicator.isHidden = !status.showActivityIndicator
        if status.showActivityIndicator {
            activityIndicatorWidthConstraint.constant = Layout.activityIndicatorWidth
            activityIndicatorTrailingMarginConstraint.constant = Metrics.veryShortMargin
            activityIndicator.startAnimating()
        } else {
            activityIndicatorWidthConstraint.constant = 0
            activityIndicatorTrailingMarginConstraint.constant = 0
            activityIndicator.stopAnimating()
        }
        actionBlock = status.actionBlock
        layoutIfNeeded()
    }
}

