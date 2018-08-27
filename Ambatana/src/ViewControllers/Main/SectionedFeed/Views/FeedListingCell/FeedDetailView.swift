import UIKit
import LGComponents

protocol FeedDetailViewDelegate: class {
    func openChat()
}

final class FeedDetailView: UIView {
    
    private var chatButtonHeightConstraint: NSLayoutConstraint?
    
    //  MARK: - subviews
    
    private let priceAndTitleView = ProductPriceAndTitleView()
    
    private let featuredListingChatButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        button.frame = CGRect(x: 0, y: 0, width: 0, height: LGUIKitConstants.mediumButtonHeight)
        button.setStyle(.primary(fontSize: .medium))
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    weak var feedDetailViewDelegate: FeedDetailViewDelegate?
    
    //  MARK: - lifecycle
    
    init(buttonHeight: CGFloat = 0.0) {
        super.init(frame: .zero)
        setupUI()
        addConstraints()
        setupButtonTarget()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - public
    
    func setupTitleAndPrice(with title: String?, price: String, priceType: String?) {
        priceAndTitleView.configUI(title: title,
                                   price: price,
                                   paymentFrequency: priceType,
                                   style: .darkText)
    }
    
    func setupButton(_ shouldHideButton: Bool, buttonHeight: CGFloat, buttonTitle: String) {
        chatButtonHeightConstraint?.constant = shouldHideButton ? 0.0 : buttonHeight
        featuredListingChatButton.setTitle(buttonTitle, for: .normal)
    }
    
    func resetUI() {
        priceAndTitleView.clearLabelTexts()
        featuredListingChatButton.setTitle(nil, for: .normal)
        chatButtonHeightConstraint?.constant = 0
    }
    
    
    //  MARK: - private
    
    private func setupUI() {
        backgroundColor = .white
        addSubviewsForAutoLayout([priceAndTitleView, featuredListingChatButton])
    }
    
    private func addConstraints() {
        chatButtonHeightConstraint = featuredListingChatButton.heightAnchor.constraint(equalToConstant: 0)
        chatButtonHeightConstraint?.isActive = true
        
        priceAndTitleView.layout(with: self).top().fillHorizontal()
        featuredListingChatButton.layout(with: priceAndTitleView)
                .below()
        featuredListingChatButton.layout(with: self)
            .fillHorizontal(by: Metrics.shortMargin)
            .bottom(by: -Metrics.shortMargin)
    }
    
    private func setupButtonTarget() {
        featuredListingChatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
    }
    
    
    //  MARK: - Actions

    @objc private func chatButtonTapped() {
        feedDetailViewDelegate?.openChat()
    }
}
