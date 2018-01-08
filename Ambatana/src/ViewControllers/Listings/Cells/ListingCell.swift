//
//  ListingCell.swift
//  LetGo
//
//  Created by AHL on 13/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import LGCoreKit

protocol ListingCellDelegate: class {
    func chatButtonPressedFor(listing: Listing)
    func relatedButtonPressedFor(listing: Listing)
}

class ListingCell: UICollectionViewCell, ReusableCell, RoundButtonDelegate {
    
    struct LayoutConstants {
        static let minHeight: CGFloat = 80.0
        static let aspectRatio: CGFloat = 198.0 / minHeight
        static let bannerAspectRatio: CGFloat = 1.3
        static let maxThumbFactor: CGFloat = 2.0
        static let featuredInfoMinHeight: CGFloat = 105.0
        static let priceViewHeight: CGFloat = 30.0
    }
    static let reusableID = "ListingCell"
    static let buttonsContainerShownHeight: CGFloat = 34
    static let stripeIconWidth: CGFloat = 14
    static let featuredListingPriceLabelHeight: CGFloat = 28

    static let priceLabelHeight: CGFloat = 22
    
    @IBOutlet weak var cellContent: UIView!
    @IBOutlet weak var thumbnailBgColorView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    @IBOutlet weak var stripeImageView: UIImageView!

    @IBOutlet weak var stripeInfoView: UIView!
    @IBOutlet weak var stripeLabel: UILabel!
    @IBOutlet weak var stripeIcon: UIImageView!
    @IBOutlet weak var stripeIconWidth: NSLayoutConstraint!

    @IBOutlet weak var featuredListingInfoView: UIView!
    @IBOutlet weak var featuredListingInfoHeight: NSLayoutConstraint!
    
    fileprivate var featuredListingPriceLabel: UILabel?
    fileprivate var featuredListingTitleLabel: UILabel?
    fileprivate var featuredListingChatButton: UIButton?
    
    fileprivate var priceLabel: UILabel?

    var isRelatedEnabled: Bool = true {
        didSet {
            relatedListingButton.isHidden = !isRelatedEnabled
            relatedListingButton.setNeedsLayout()
        }
    }
    var relatedListingButton = RoundButton()

    var listing: Listing?
    weak var delegate: ListingCellDelegate?

    var likeButtonEnabled: Bool = true
    var chatButtonEnabled: Bool = true

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.8 : 1.0
        }
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
        self.setAccessibilityIds()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }


    // MARK: - Public / internal methods

    func setupBackgroundColor(id: String?) {
        thumbnailBgColorView.backgroundColor = UIColor.placeholderBackgroundColor(id)
    }

    func setupImageUrl(_ imageUrl: URL) {
        thumbnailImageView.lg_setImageWithURL(imageUrl, placeholderImage: nil, completion: {
            [weak self] (result, url) -> Void in
            if let (_, cached) = result.value, !cached {
                self?.thumbnailImageView.alpha = 0
                UIView.animate(withDuration: 0.4, animations: { self?.thumbnailImageView.alpha = 1 })
            }
        })
    }

    func setupFreeStripe() {
        stripeIconWidth.constant = ListingCell.stripeIconWidth
        stripeImageView.image = UIImage(named: "stripe_white")
        stripeIcon.image = UIImage(named: "ic_heart")
        stripeLabel.text = LGLocalizedString.productFreePrice
        stripeLabel.textColor = UIColor.primaryColor
        stripeImageView.isHidden = false
        stripeInfoView.isHidden = false
    }

    func setupFeaturedStripe(withTextColor textColor: UIColor) {
        stripeIconWidth.constant = 0
        stripeImageView.image = UIImage(named: "stripe_white")
        stripeIcon.image = nil
        stripeLabel.text = LGLocalizedString.bumpUpProductCellFeaturedStripe
        stripeLabel.textColor = textColor
        stripeImageView.isHidden = false
        stripeInfoView.isHidden = false
    }

    func setupFeaturedListingInfoWith(price: String, title: String?, isMine: Bool) {
        featuredListingPriceLabel = UILabel()
        featuredListingTitleLabel = UILabel()
        featuredListingChatButton = UIButton(type: .custom)

        featuredListingInfoView.translatesAutoresizingMaskIntoConstraints = false
        featuredListingPriceLabel?.translatesAutoresizingMaskIntoConstraints = false
        featuredListingTitleLabel?.translatesAutoresizingMaskIntoConstraints = false
        featuredListingChatButton?.translatesAutoresizingMaskIntoConstraints = false

        guard let featuredListingPriceLabel = featuredListingPriceLabel,
            let featuredListingTitleLabel = featuredListingTitleLabel,
            let featuredListingChatButton = featuredListingChatButton else {
                featuredListingInfoHeight.constant = 0
                return
        }

        featuredListingInfoView.addSubviews([featuredListingPriceLabel, featuredListingTitleLabel, featuredListingChatButton])

        featuredListingPriceLabel.text = price
        featuredListingPriceLabel.font = UIFont.systemBoldFont(size: 23)
        featuredListingPriceLabel.adjustsFontSizeToFitWidth = true

        featuredListingTitleLabel.text = title
        featuredListingTitleLabel.font = UIFont.mediumBodyFont
        featuredListingTitleLabel.textColor = UIColor.darkGrayText
        featuredListingTitleLabel.numberOfLines = 2

        featuredListingChatButton.frame = CGRect(x: 0, y: 0, width: 0, height: LGUIKitConstants.mediumButtonHeight)
        featuredListingChatButton.setStyle(.primary(fontSize: .medium))
        featuredListingChatButton.setTitle(LGLocalizedString.bumpUpProductCellChatNowButton, for: .normal)
        featuredListingChatButton.addTarget(self, action: #selector(openChat), for: .touchUpInside)

        // layouts
        
        //featuredInfoViewTopToImageViewBottomConstraint.isActive = true

        let priceTopMargin = Metrics.shortMargin
        featuredListingPriceLabel.layout(with: featuredListingInfoView)
            .top(by: priceTopMargin)
            .left(by: Metrics.shortMargin)
            .right(by: -Metrics.shortMargin)
        featuredListingPriceLabel.layout().height(ListingCell.featuredListingPriceLabelHeight)

        featuredListingTitleLabel.layout(with: featuredListingInfoView)
            .left(by: Metrics.shortMargin)
            .right(by: -Metrics.shortMargin)

        var titleHeight: CGFloat = 0.0
        var titleTopMargin: CGFloat = 0.0
        if let title = title {
            let labelWidth = contentView.width - (Metrics.shortMargin * 2.0)
            titleHeight = title.heightForWidth(width: labelWidth, maxLines: 2, withFont: featuredListingTitleLabel.font)
            titleTopMargin = Metrics.veryShortMargin
        }

        featuredListingTitleLabel.layout(with: featuredListingPriceLabel).below(by: titleTopMargin)
        featuredListingTitleLabel.layout().height(titleHeight)

        let buttonTopMargin = isMine ? 0.0 : Metrics.shortMargin
        let buttonHeight = isMine ? 0.0 : LGUIKitConstants.mediumButtonHeight
        let buttonBottomMargin = Metrics.shortMargin

        featuredListingChatButton.layout().height(buttonHeight)
        featuredListingChatButton.layout(with: featuredListingInfoView)
            .left(by: Metrics.shortMargin)
            .right(by: -Metrics.shortMargin)
            .bottom(by: -buttonBottomMargin)
        featuredListingChatButton.layout(with: featuredListingTitleLabel).below(by: buttonTopMargin)

        let totalMarginsHeight = priceTopMargin + titleTopMargin + buttonTopMargin + buttonBottomMargin

        featuredListingInfoHeight.constant = ListingCell.featuredListingPriceLabelHeight + titleHeight + buttonHeight + totalMarginsHeight
    }

    func updateInfoViewHeightToZero() {
        featuredListingInfoHeight.constant = 0
    }
    
    func setupPriceView(price: String) {
        priceLabel = UILabel()
        
        featuredListingInfoView.translatesAutoresizingMaskIntoConstraints = false
        priceLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let priceLabel = priceLabel else {
            featuredListingInfoHeight.constant = 0
            return
        }
        
        featuredListingInfoView.addSubview(priceLabel)
        
        priceLabel.text = price
        priceLabel.font = UIFont.systemBoldFont(size: 18)
        priceLabel.adjustsFontSizeToFitWidth = true
        
        let priceTopMargin = Metrics.shortMargin
        priceLabel.layout(with: featuredListingInfoView)
            .top(by: priceTopMargin)
            .left(by: Metrics.shortMargin)
            .right(by: -Metrics.shortMargin)
        priceLabel.layout().height(ListingCell.featuredListingPriceLabelHeight)
        
        featuredListingInfoHeight.constant = ListingCell.priceLabelHeight + Metrics.shortMargin*2
    }

    // MARK: - Private methods

    // Sets up the UI
    private func setupUI() {
        cellContent.layer.cornerRadius = LGUIKitConstants.listingCellCornerRadius
        let rotation = CGFloat(Double.pi/4)
        stripeInfoView.transform = CGAffineTransform(rotationAngle: rotation)
        stripeLabel.textColor = UIColor.redText
        // HIDDEN for the moment while we experiment with 3 columns
        stripeInfoView.isHidden = true
        stripeImageView.isHidden = true

        setupRelatedListingButton()
    }

    private func setupRelatedListingButton() {
        relatedListingButton.translatesAutoresizingMaskIntoConstraints = false
        cellContent.addSubview(relatedListingButton)
        relatedListingButton.layout(with: thumbnailImageView).bottom(to: .bottom, by: 0)
        relatedListingButton.layout(with: thumbnailImageView).trailing(to: .trailing, by: 0)
        relatedListingButton.layout(with: cellContent).proportionalWidth(multiplier: 0.3,
                                                                         add: 0,
                                                                         relatedBy: .equal,
                                                                         priority: UILayoutPriority.required,
                                                                         constraintBlock: nil)
        relatedListingButton.layout().widthProportionalToHeight()

        relatedListingButton.delegate = self
    }

    // Resets the UI to the initial state
    private func resetUI() {
        setupBackgroundColor(id: nil)
        thumbnailImageView.image = nil
        stripeImageView.image = nil
        stripeLabel.text = ""
        stripeIcon.image = nil
        featuredListingTitleLabel?.text = nil
        featuredListingPriceLabel?.text = nil

        self.delegate = nil
        self.listing = nil

        for featuredInfoSubview in featuredListingInfoView.subviews {
            featuredInfoSubview.removeFromSuperview()
        }

        relatedListingButton.compress()
    }

    @objc private func openChat() {
        guard let listing = listing else { return }
        delegate?.chatButtonPressedFor(listing: listing)
    }

    private func setAccessibilityIds() {
        accessibilityId = .listingCell
        thumbnailImageView.accessibilityId = .listingCellThumbnailImageView
        stripeImageView.accessibilityId = .listingCellStripeImageView
        stripeLabel.accessibilityId = .listingCellStripeLabel
        stripeIcon.accessibilityId = .listingCellStripeIcon

        featuredListingPriceLabel?.accessibilityId = .listingCellFeaturedPrice
        featuredListingTitleLabel?.accessibilityId = .listingCellFeaturedTitle
        featuredListingChatButton?.accessibilityId = .listingCellFeaturedChatButton
    }
    
    // MARK: RoundButtonDelegate
    
    func roundedButtonActionDidTrigger(_ button: RoundButton) {
        guard let listing = self.listing else { return }
        self.delegate?.relatedButtonPressedFor(listing: listing)
    }
}
