import LGComponents
private enum Layout {
    static let buttonHeight: CGFloat = 50
    static let imageHeight: CGFloat = 100
}
final class AffiliationStoreErrorView: UIView {
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemBoldFont(size: 28)
        label.textColor = .lgBlack
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()

    private let retryButton = LetgoButton(withStyle: .primary(fontSize: .medium))
    private var cta: UIAction? = nil

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .white

        let layoutGuide = UILayoutGuide()
        addLayoutGuide(layoutGuide)
        addSubviewsForAutoLayout([imageView, messageLabel, retryButton])
        [
            layoutGuide.centerXAnchor.constraint(equalTo: centerXAnchor),
            layoutGuide.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -Metrics.veryBigMargin),

            imageView.widthAnchor.constraint(equalToConstant: Layout.imageHeight),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),

            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.veryBigMargin),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.veryBigMargin),
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2*Metrics.veryBigMargin),

            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 2*Metrics.bigMargin),
            retryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.veryBigMargin),
            retryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.veryBigMargin),
            retryButton.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            retryButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ].activate()
    }

    func populate(message: String, image: UIImage, action: UIAction?) {
        messageLabel.text = message
        imageView.image = image
        if let action = action {
            retryButton.configureWith(uiAction: action)
            retryButton.isHidden = false
        } else {
            retryButton.isHidden = true
        }
        self.cta = action
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
    }

    @objc private func didTapRetry() {
        cta?.action()
    }
}
