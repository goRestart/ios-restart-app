import LGComponents

protocol BlockingPostingLoadingViewDelegate: class {
    func didPressRetryButton()
}

class BlockingPostingLoadingView: UIView {
    
    private static let loadingIndicatorHeight: CGFloat = 100
    private static let loadingIndicatorWidth: CGFloat = 100
    private static let loadingIndicatorCenterYMargin: CGFloat = -100
    private static let retryButtonHeight: CGFloat = 50
    private static let retryButtonWidth: CGFloat = 100
    private static let messageLabelHeight: CGFloat = 66
    
    private let loadingIndicator: LoadingIndicator = LoadingIndicator(frame: CGRect(x: 0,
                                                                                    y: 0,
                                                                                    width: BlockingPostingLoadingView.loadingIndicatorWidth,
                                                                                    height: BlockingPostingLoadingView.loadingIndicatorHeight))
    private let messageLabel: UILabel = UILabel()
    private let retryButton: LetgoButton = LetgoButton(type: .custom)
    
    weak var delegate: BlockingPostingLoadingViewDelegate?
    
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        retryButton.setRoundedCorners()
    }
    

    // MARK: - UI
    
    private func setupUI() {
        backgroundColor = .clear
        
        messageLabel.textColor = UIColor.white
        messageLabel.font = UIFont.postingFlowBody
        messageLabel.numberOfLines = 2
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.6

        retryButton.setStyle(.primary(fontSize: .medium))
        retryButton.setTitle(R.Strings.commonErrorListRetryButton, for: .normal)
        retryButton.addTarget(self, action: #selector(BlockingPostingLoadingView.retryButtonAction), for: .touchUpInside)

        retryButton.isHidden = true
    }
    
    private func setupConstraints() {
        let subviews: [UIView] = [loadingIndicator, messageLabel, retryButton]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        loadingIndicator.layout()
            .height(BlockingPostingLoadingView.loadingIndicatorHeight)
            .width(BlockingPostingLoadingView.loadingIndicatorWidth)
        loadingIndicator.layout(with: self)
            .leading(by: Metrics.veryBigMargin)
            .centerY(by: BlockingPostingLoadingView.loadingIndicatorCenterYMargin)
        
        messageLabel.layout().height(BlockingPostingLoadingView.messageLabelHeight)
        messageLabel.layout(with: self)
            .centerY()
            .fillHorizontal(by: Metrics.margin)
        
        retryButton.layout()
            .height(BlockingPostingLoadingView.retryButtonHeight)
            .width(BlockingPostingLoadingView.retryButtonWidth)
        retryButton.layout(with: self).leading(by: Metrics.veryBigMargin)
        retryButton.layout(with: messageLabel).top(to: .bottom, by: Metrics.margin)
    }
    
    
    // MARK: - UI Actions
    
    @objc func retryButtonAction() {
        delegate?.didPressRetryButton()
    }
    
    
    // MARK: - UI Updates
    
    func updateWith(message: String, isError: Bool, isAnimated: Bool) {
        messageLabel.text = message
        retryButton.isHidden = !isError
        if isAnimated && !loadingIndicator.isAnimating {
            loadingIndicator.startAnimating()
        } else if !isAnimated && loadingIndicator.isAnimating {
            loadingIndicator.stopAnimating(correctState: !isError)
        }
    }
    
    func updateMessage(_ message: String) {
        messageLabel.text = message
    }
}

