//
//  BlockingPostingLoadingView.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 07/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

protocol BlockingPostingLoadingViewDelegate: class {
    func didPressRetryButton()
}

class BlockingPostingLoadingView: UIView {
    
    private static let retryButtonHeight: CGFloat = 50
    private static let retryButtonWidth: CGFloat = 100
    
    private let loadingIndicator: LoadingIndicator = LoadingIndicator(frame: CGRect(x: 100, y:100, width:100, height: 100))
    private let messageLabel: UILabel = UILabel()
    private let retryButton: UIButton = UIButton(type: .custom)
    
    weak var delegate: BlockingPostingLoadingViewDelegate?
    
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
        //setupRx()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - UI
    
    private func setupUI() {
        backgroundColor = .clear
        
        messageLabel.textColor = UIColor.white
        messageLabel.font = UIFont.body
        messageLabel.numberOfLines = 2
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.6

        retryButton.setStyle(.primary(fontSize: .medium))
        retryButton.setTitle(LGLocalizedString.commonErrorListRetryButton, for: .normal)
        retryButton.addTarget(self, action: #selector(BlockingPostingLoadingView.retryButtonAction), for: .touchUpInside)
        retryButton.layer.cornerRadius = BlockingPostingLoadingView.retryButtonHeight/2

        retryButton.isHidden = true
    }
    
    private func setupConstraints() {
        let subviews: [UIView] = [loadingIndicator, messageLabel, retryButton]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        loadingIndicator.layout()
            .height(100)
            .width(100)
        loadingIndicator.layout(with: self)
            .leading(by: 30)
            .centerY(by: -100)
        
        messageLabel.layout().height(50)
        messageLabel.layout(with: self)
            .centerY()
            .fillHorizontal(by: Metrics.margin)
        
        retryButton.layout()
            .height(BlockingPostingLoadingView.retryButtonHeight)
            .width(BlockingPostingLoadingView.retryButtonWidth)
        retryButton.layout(with: self).leading(by: 30)
        retryButton.layout(with: messageLabel).top(to: .bottom, by: Metrics.margin)
    }
    
    
    // MARK: - UI Actions
    
    @objc func retryButtonAction() {
        delegate?.didPressRetryButton()
    }
    
    
    // MARK: - State updating
    
    func updateToLoading(message: String) {
        messageLabel.text = message
        retryButton.isHidden = true
        loadingIndicator.startAnimating()
    }
    
    func updateToSuccess(message: String) {
        messageLabel.text = message
        retryButton.isHidden = true
        loadingIndicator.stopAnimating(correctState: true)
    }
    
    func updateToError(message: String) {
        messageLabel.text = message
        retryButton.isHidden = false
        loadingIndicator.stopAnimating(correctState: false)
    }
}

