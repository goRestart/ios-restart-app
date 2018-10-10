
import UIKit
import LGCoreKit
import LGComponents

final class MultiListingPostedListingCell: UICollectionViewCell, ReusableCell {
    
    private struct Layout {
        static let editButtonMinimumWidth: CGFloat = 56.0
        static let titleFontSize: CGFloat = 16.0
        static let subtitleFontSize: CGFloat = 15.0
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Metrics.veryShortMargin
        imageView.backgroundColor = UIColor.lightGray
        return imageView
    }()
    
    private let editButton: LetgoButton = {
        let button = LetgoButton(withStyle: .secondary(fontSize: .verySmall,
                                                       withBorder: true))
        button.setTitle(R.Strings.commonEdit,
                        for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: Layout.titleFontSize)
        label.textColor = UIColor.blackText
        label.textAlignment = NSTextAlignment.left
        label.numberOfLines = 2
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: Layout.subtitleFontSize)
        label.textColor = UIColor.gray
        label.textAlignment = NSTextAlignment.left
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    private let cardView: CardView = CardView(frame: CGRect.zero,
                                              backgroundColour: UIColor.white,
                                              cornerRadius: LGUIKitConstants.smallCornerRadius)
    
    private var editAction: (() -> Void)?
    
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEditButton()
        setupConstraints()
        reset()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    
    // MARK: Public methods
    
    func setup(withListing listing: Listing,
               editAction: @escaping (() -> Void)) {
        
        self.editAction = editAction
        
        setupImageView(forListing: listing)
        titleLabel.text = listing.title
        subtitleLabel.text = listing.priceString()
    }
    
    
    // MARK:- Layout & Friends
    
    private func styleView() {
        backgroundColor = UIColor.clear
    }
    
    private func setupEditButton() {
        editButton.addTarget(self,
                             action: #selector(editButtonTapped),
                             for: .touchUpInside)
        editButton.set(accessibilityId: .postingInfoEditButton)
    }
    
    private func setupConstraints() {
        addSubviewsForAutoLayout([
            cardView,
            imageView,
            titleLabel,
            subtitleLabel,
            editButton
            ])
        
        cardView.layout(with: self)
            .fillVertical(by: Metrics.veryShortMargin)
            .fillHorizontal(by: Metrics.margin)
        
        imageView.layout(with: cardView)
            .left(to: .left, by: Metrics.shortMargin)
            .top(to: .top, by: Metrics.shortMargin)
            .bottom(to: .bottom, by: -Metrics.shortMargin)
        
        imageView.layout().widthProportionalToHeight()
        
        editButton.layout(with: cardView)
            .right(to: .right, by: -Metrics.shortMargin)
            .centerY()
        editButton.layout()
            .height(LGUIKitConstants.smallButtonHeight)
            .width(Layout.editButtonMinimumWidth)
        
        titleLabel.layout(with: editButton)
            .right(to: .left, by: -Metrics.shortMargin)
        
        titleLabel.layout(with: imageView)
            .left(to: .right, by: Metrics.shortMargin)
        
        titleLabel.layout(with: cardView)
            .centerY(to: .centerY, by: -Metrics.shortMargin)
            .top(to: .top, by: Metrics.bigMargin, relatedBy: .greaterThanOrEqual, priority: .defaultHigh)
        
        subtitleLabel.layout(with: editButton)
            .right(to: .left, by: -Metrics.shortMargin)
        
        subtitleLabel.layout(with: imageView)
            .left(to: .right, by: Metrics.shortMargin)
        
        subtitleLabel.layout(with: titleLabel)
            .top(to: .bottom, by: Metrics.veryShortMargin)
        
        subtitleLabel.layout(with: cardView)
            .bottom(to: .bottom, by: -Metrics.margin, relatedBy: .greaterThanOrEqual, priority: .defaultLow)
    }
    
    private func setupImageView(forListing listing: Listing) {
        guard let imageURL = listing.images.first?.fileURL else { return }
        imageView.lg_setImageWithURL(imageURL,
                                     placeholderImage: nil,
                                     completion: { [weak self] (result, url) -> Void in
                                        self?.imageView.alpha = 0
                                        UIView.animate(withDuration: 0.25, animations: { self?.imageView.alpha = 1 })
        })
    }
    
    @objc private func editButtonTapped() {
        editAction?()
    }
    
    private func reset() {
        imageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        editAction = nil
    }
}
