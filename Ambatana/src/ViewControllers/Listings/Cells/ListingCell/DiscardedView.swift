import UIKit
import LGComponents

final class DiscardedView: UIView {
    private let moreOptionsButton: UIButton = {
        let button = UIButton(frame: .zero)
        let image = R.Asset.IconsButtons.icMoreOptions.image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(image, for: UIControlState.normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        return button
    }()
    private let title: UILabel = {
        let label = UILabel()
        label.text = R.Strings.discarded
        label.font = UIFont.systemFont(size: 25)
        label.textAlignment = .center
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private let reason: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 14)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    private let editButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .small))
        button.setTitle(R.Strings.discardedProductsEdit, for: .normal)
        return button
    }()
    
    private let blurEffectView: UIView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    var editListingCallback: (() -> Void)?
    var moreOptionsCallback: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        clipsToBounds = true
        backgroundColor = .clear
        layer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        moreOptionsButton.addTarget(self, action: #selector(moreOptions(sender:)), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editListing(sender:)), for: .touchUpInside)
        addSubviews([blurEffectView, moreOptionsButton, title, reason, editButton])
    }
    
    private func setupConstraints() {
        let moreOptionsSide: CGFloat = 24.0
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        blurEffectView.layout(with: self).fill()
        moreOptionsButton.layout(with: self).top(by: Metrics.shortMargin).right(by: -Metrics.shortMargin)
        moreOptionsButton.layout().height(moreOptionsSide).width(moreOptionsSide)
        reason.layout(with: self).fillHorizontal(by: Metrics.shortMargin)
        reason.layout(with: self).centerY()
        title.layout(with: reason).above(by: -Metrics.veryShortMargin)
        title.layout(with: self).fillHorizontal(by: Metrics.shortMargin)
        editButton.layout(with: self).fillHorizontal(by: Metrics.shortMargin)
        editButton.layout(with: reason).below(by: Metrics.margin)
        editButton.layout().height(LGUIKitConstants.smallButtonHeight)
    }
    
    @objc private func moreOptions(sender: UIButton) {
        moreOptionsCallback?()
    }
    
    @objc private func editListing(sender: UIButton) {
        editListingCallback?()
    }
    
    func set(reason: String) {
        self.reason.text = reason
    }
    
}
