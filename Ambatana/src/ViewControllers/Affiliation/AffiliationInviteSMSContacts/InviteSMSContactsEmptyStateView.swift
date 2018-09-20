import LGComponents

private enum Layout {
    static let buttonHeight: CGFloat = 50
}
final class InviteSMSContactsEmptyStateView: UIView {
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
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
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
        addSubviewsForAutoLayout([messageLabel, retryButton])
        [
            layoutGuide.centerXAnchor.constraint(equalTo: centerXAnchor),
            layoutGuide.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -Metrics.veryBigMargin),
            
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.margin),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.margin),
            messageLabel.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 2*Metrics.veryBigMargin),
            
            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 2*Metrics.bigMargin),
            retryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.margin),
            retryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.margin),
            retryButton.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            retryButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
            ].activate()
        
        retryButton.alpha = cta != nil ? 0 : 1
    }
    
    func populate(message: String, action: UIAction?) {
        messageLabel.text = message
        if let action = action {
            retryButton.configureWith(uiAction: action)
            self.cta = action
            retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        }
    }
    
    @objc private func didTapRetry() {
        cta?.action()
    }
}
