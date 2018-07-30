import Foundation
import LGComponents

final class LPInterstitialView: UIView {
    private enum Layout {
        static let banerTop: CGFloat = 50
        static let headlineSide: CGFloat = 45
        static let buttonHeight: CGFloat = 50
        static let bannerMargin: CGFloat = 60
    }

    private let closeButton: UIButton = {
        let close = UIButton.init(type: .custom)
        close.setImage(R.Asset.CongratsScreenImages.icCloseRed.image, for: .normal)
        return close
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
        label.font = UIFont.systemBoldFont(size: 29)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.6
        label.baselineAdjustment = .alignCenters
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        return label
    }()

    private let subHeadlineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemRegularFont(size: 17)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.8
        label.baselineAdjustment = .alignCenters
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        return label
    }()

    private let actionButton = LetgoButton(withStyle: .primary(fontSize: .medium))

    private let dismissButton: LetgoButton = {
        let button = LetgoButton(withStyle: .secondary(fontSize: .medium, withBorder: true))
        button.setTitle(R.Strings.commonCancel, for: .normal)
        return button
    }()

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .white
        setupConstraints()
    }

    private func setupConstraints() {
        let textLayoutGuide = UILayoutGuide()
        addLayoutGuide(textLayoutGuide)
        addSubviewsForAutoLayout([closeButton, bannerImageView, headlineLabel, subHeadlineLabel, actionButton])
        var constraints: [NSLayoutConstraint] = []
        constraints.append(contentsOf: [
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            closeButton.topAnchor.constraint(equalTo: topAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: Layout.buttonHeight),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor),

            bannerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bannerImageView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.banerTop),
            bannerImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalTo: bannerImageView.widthAnchor, constant: 1.10),

            textLayoutGuide.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: Metrics.shortMargin),

            headlineLabel.topAnchor.constraint(greaterThanOrEqualTo: textLayoutGuide.topAnchor),
            headlineLabel.bottomAnchor.constraint(equalTo: textLayoutGuide.centerYAnchor, constant: -Metrics.veryShortMargin),
            headlineLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.headlineSide),
            headlineLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.headlineSide),

            subHeadlineLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.headlineSide),
            subHeadlineLabel.topAnchor.constraint(equalTo: textLayoutGuide.centerYAnchor, constant: Metrics.veryShortMargin),
            subHeadlineLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.headlineSide),
            subHeadlineLabel.bottomAnchor.constraint(lessThanOrEqualTo: textLayoutGuide.bottomAnchor),
            
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.veryBigMargin),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.veryBigMargin),
            actionButton.topAnchor.constraint(equalTo: textLayoutGuide.bottomAnchor, constant: Metrics.veryBigMargin),
            actionButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.margin)
        ])
        NSLayoutConstraint.activate(constraints)
    }
}

extension LPInterstitialView: LPMessageView {
    var headline: String {
        get { return headlineLabel.text ?? "" }
        set { headlineLabel.text = newValue }
    }

    var action: String {
        get { return actionButton.titleLabel?.text ?? "" }
        set { actionButton.setTitle(newValue, for: .normal) }
    }

    var image: UIImage? {
        get { return bannerImageView.image }
        set { bannerImageView.image = newValue }
    }

    var subHeadline: String {
        get { return subHeadlineLabel.text ?? "" }
        set { subHeadlineLabel.text = newValue }
    }
    
    var dismissControl: UIControl? { return self.dismissButton }
    var closeControl: UIControl? { return self.closeButton }
    var actionControl: UIControl? { return self.actionButton }
}
