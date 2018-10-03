import LGComponents
import DeviceGuru

private enum Layout {
    enum Size {
        static let separator = CGSize(width: UIViewNoIntrinsicMetric, height: 1)
        static let button = CGSize(width: UIViewNoIntrinsicMetric, height: 50)
    }
    enum CornerRadius {
        static let container: CGFloat = 16
    }
}

final class AffiliationModalView: UIView {
    private let edges: UIEdgeInsets
    private let iconFactor: CGFloat
    private var twoButtonsConstraints: [NSLayoutConstraint] = []
    private var oneButtonConstraints: [NSLayoutConstraint] = []

    private let container: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = Layout.CornerRadius.container
        return container
    }()
    
    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.Asset.Affiliation.Error.errorFeatureUnavailable.image
        return imageView
    }()

    private let headingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemBoldFont(size: 26)
        label.textAlignment = .left
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .lgBlack
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private let subHeadingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemBoldFont(size: 26)
        label.textAlignment = .left
        label.textColor = .lgBlack
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .lineGray
        return view
    }()

    private let primary: UIButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        return button
    }()
    private var primaryCTA: (()->())?

    private let secondary: UIButton = {
        let button = LetgoButton(withStyle: .link(fontSize: .big))
        button.alpha = 0
        return button
    }()
    private var secondaryCTA: (()->())?


    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override init(frame: CGRect) {
        self.edges = DeviceFamily.current.containerEdges
        self.iconFactor = DeviceFamily.current.iconFactor
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        addSubviewsForAutoLayout([container, icon, headingLabel, subHeadingLabel, separator, primary, secondary])
        [
            container.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: edges.top),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edges.left),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edges.right),
            container.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -edges.bottom),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),

            icon.topAnchor.constraint(equalTo: container.topAnchor, constant: Metrics.bigMargin),
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Metrics.veryBigMargin),
            icon.widthAnchor.constraint(equalTo: widthAnchor, multiplier: iconFactor),
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor),

            headingLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: Metrics.margin),
            headingLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Metrics.veryBigMargin),
            headingLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Metrics.veryBigMargin),

            subHeadingLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: Metrics.bigMargin),
            subHeadingLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor,
                                                     constant: Metrics.veryBigMargin),
            subHeadingLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor,
                                                      constant: -Metrics.veryBigMargin),

            separator.topAnchor.constraint(equalTo: subHeadingLabel.bottomAnchor, constant: Metrics.veryBigMargin),
            separator.heightAnchor.constraint(equalToConstant: Layout.Size.separator.height),
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Metrics.veryBigMargin),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Metrics.veryBigMargin),

            primary.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: Metrics.veryBigMargin),
            primary.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Metrics.veryBigMargin),
            primary.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Metrics.veryBigMargin),
            primary.heightAnchor.constraint(equalToConstant: Layout.Size.button.height),
        ].activate()

        twoButtonsConstraints.append(contentsOf: [
            secondary.topAnchor.constraint(equalTo: primary.bottomAnchor, constant: Metrics.margin),
            secondary.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Metrics.veryBigMargin),
            secondary.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Metrics.veryBigMargin),
            secondary.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Metrics.veryBigMargin),
            secondary.heightAnchor.constraint(equalToConstant: Layout.Size.button.height),
        ])
        twoButtonsConstraints.activate()
        oneButtonConstraints.append(primary.bottomAnchor.constraint(equalTo: container.bottomAnchor,
                                                                    constant: -Metrics.veryBigMargin))
    }

    func populate(with data: AffiliationModalData) {
        headingLabel.text = data.headline
        subHeadingLabel.text = data.subheadline
        icon.image = data.icon
        primary.setTitle(data.primary.text ?? "",  for: .normal)
        primaryCTA = data.primary.action
        primary.removeTarget(self, action: nil, for: .allEvents)
        primary.addTarget(self, action: #selector(didTapPrimary), for: .touchUpInside)
        if let secondaryAction = data.secondary {
            secondary.alpha = 1
            twoButtonsConstraints.activate()
            oneButtonConstraints.deactivate()
            secondary.setTitle(secondaryAction.text ?? "", for: .normal)
            secondaryCTA = secondaryAction.action
            secondary.removeTarget(self, action: nil, for: .allEvents)
            secondary.addTarget(self, action: #selector(didTapSecondary), for: .touchUpInside)
        } else {
            secondary.alpha = 0
            twoButtonsConstraints.deactivate()
            oneButtonConstraints.activate()
        }
    }

    @objc private func didTapPrimary() {
        primaryCTA?()
    }

    @objc private func didTapSecondary() {
        secondaryCTA?()
    }
}

fileprivate extension DeviceFamily {
    var containerEdges: UIEdgeInsets {
        switch self {
        case .iPhone4:
            return UIEdgeInsets(top: Metrics.margin,
                                left: Metrics.shortMargin,
                                bottom: Metrics.margin,
                                right: Metrics.shortMargin)
        case .iPhone5:
            return UIEdgeInsets(top: Metrics.veryBigMargin,
                                left: Metrics.bigMargin,
                                bottom: Metrics.veryBigMargin,
                                right: Metrics.bigMargin)
        default:
            return UIEdgeInsets(top: 2.5*Metrics.veryBigMargin,
                                left: 2*Metrics.veryBigMargin,
                                bottom: 2.5*Metrics.veryBigMargin,
                                right: 2*Metrics.veryBigMargin)
        }
    }

    var iconFactor: CGFloat {
        switch self {
        case .iPhone4: return 0.25
        default: return 0.3
        }
    }
}
