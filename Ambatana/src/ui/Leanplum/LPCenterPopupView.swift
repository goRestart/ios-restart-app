import Foundation
import LGComponents

final class LPCenterPopupView: UIView {
    private enum Layout {
        static let baseMargin: CGFloat = 40
        static let bannerTopMargin: CGFloat = 115
        static let buttonHeight: CGFloat = 45
    }
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 16.0
        return view
    }()

    private let bannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return imageView
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemBoldFont(size: 23)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.6
        label.baselineAdjustment = .alignCenters
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private let subHeadlineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemRegularFont(size: 15)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.7
        label.baselineAdjustment = .alignCenters
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private let actionButton = LetgoButton(withStyle: .primary(fontSize: .medium))

    private let dismissButton: LetgoButton = {
        let button = LetgoButton(withStyle: .secondary(fontSize: .medium, withBorder: false))
        button.setTitle(R.Strings.commonCancel, for: .normal)
        return button
    }()

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        setupConstraints()
    }

    private func setupConstraints() {
        let topLayoutGuide = UILayoutGuide()
        let bottomLayoutGuide = UILayoutGuide()
        addLayoutGuide(topLayoutGuide)
        addLayoutGuide(bottomLayoutGuide)

        addSubviewForAutoLayout(containerView)
        containerView.addSubviewsForAutoLayout([bannerImageView, headlineLabel, subHeadlineLabel, actionButton])

        var constraints: [NSLayoutConstraint] = []
        constraints.append(contentsOf: [
            topLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
            bottomLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            topLayoutGuide.heightAnchor.constraint(equalTo: bottomLayoutGuide.heightAnchor),
            topLayoutGuide.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1),

            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.topAnchor.constraint(greaterThanOrEqualTo: topLayoutGuide.bottomAnchor),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: bottomLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.baseMargin),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.baseMargin),

            bannerImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bannerImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalTo: bannerImageView.widthAnchor, multiplier: 0.65),

            headlineLabel.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: Metrics.veryBigMargin),
            headlineLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Metrics.bigMargin),
            headlineLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                    constant: -Metrics.bigMargin),

            subHeadlineLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: Metrics.shortMargin),
            subHeadlineLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                      constant: Metrics.bigMargin),
            subHeadlineLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                       constant: -Metrics.bigMargin),

            actionButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Metrics.bigMargin),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Metrics.bigMargin),
            actionButton.topAnchor.constraint(equalTo: subHeadlineLabel.bottomAnchor, constant: Metrics.bigMargin),
            ])

        if DeviceFamily.current == .iPhone4 {
            constraints.append(contentsOf: [
                actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Metrics.bigMargin)
                ])
        } else {
            addSubviewForAutoLayout(dismissButton)
            constraints.append(contentsOf: [
                dismissButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                       constant: Metrics.bigMargin),
                dismissButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                                      constant: -Metrics.bigMargin),

                dismissButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                        constant: -Metrics.bigMargin),

                dismissButton.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: Metrics.shortMargin),
                dismissButton.heightAnchor.constraint(equalTo: dismissButton.heightAnchor)
                ])
        }

        NSLayoutConstraint.activate(constraints)
    }
}

extension LPCenterPopupView: LPMessageView {
    var action: String {
        get { return actionButton.titleLabel?.text ?? "" }
        set { actionButton.setTitle(newValue, for: .normal) }
    }

    var headline: String {
        get { return headlineLabel.text ?? "" }
        set { headlineLabel.text = newValue }
    }

    var subHeadline: String {
        get { return subHeadlineLabel.text ?? "" }
        set { subHeadlineLabel.text = newValue }
    }

    var image: UIImage? {
        get { return bannerImageView.image }
        set { bannerImageView.image = newValue }
    }

    var dismissControl: UIControl? { return self.dismissButton }
    var closeControl: UIControl? { return nil }
    var actionControl: UIControl? { return actionButton }
}
