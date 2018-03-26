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
    func editPressedForDiscarded(listing: Listing)
    func moreOptionsPressedForDiscarded(listing: Listing)
}

final class ListingCell: UICollectionViewCell, ReusableCell, RoundButtonDelegate {
    
    static let stripeIconWidth: CGFloat = 14

    @IBOutlet weak var cellContent: UIView!
    
    @IBOutlet weak var thumbnailBgColorView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var thumbnailImageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var stripeImageView: UIImageView!
    @IBOutlet weak var stripeInfoView: UIView!
    @IBOutlet weak var stripeLabel: UILabel!
    @IBOutlet weak var stripeIcon: UIImageView!
    @IBOutlet weak var stripeIconWidth: NSLayoutConstraint!

    @IBOutlet weak var featuredListingInfoView: UIView!

    private let featuredListingChatButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        button.frame = CGRect(x: 0, y: 0, width: 0, height: LGUIKitConstants.mediumButtonHeight)
        button.setStyle(.primary(fontSize: .medium))
        return button
    }()
    
    private let featureDetailView = ProductPriceAndTitleView()
    private let distanceInfoView = DistanceInfoView(frame: .zero)
    
    private let discardedView: DiscardedView = {
        let view = DiscardedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
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
        setupUI()
        resetUI()
        setAccessibilityIds()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }


    // MARK: - Public / internal methods

    func setupBackgroundColor(id: String?) {
        thumbnailBgColorView.backgroundColor = UIColor.placeholderBackgroundColor(id)
    }

    func setupImageUrl(_ imageUrl: URL, imageSize: CGSize) {
        thumbnailImageViewHeight.constant = imageSize.height
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

    func setupFeaturedListingInfoWith(price: String, title: String?, isMine: Bool, hideProductDetail: Bool) {
        featureDetailView.update(with: price,
                                 title: title,
                                 textStyle: hideProductDetail ? .whiteText : .darkText)
        setupFeaturedListingChatButton()
        layoutFeatureListArea(isMine: isMine, hideProductDetail: hideProductDetail)
    }
    
    func setupNonFeaturedProductInfoUnderImage(price: String, title: String?, shouldShow: Bool) {
        if shouldShow {
            featureDetailView.update(with: price, title: title, textStyle: .darkText)
            showDetail()
        }
    }
    
    func showCompleteProductInfoInImage(price: String, title: String?, distance: Double?) {
        setupProductDetailInImage(price: price, title: title)
        if let distance = distance {
            addDistanceViewInImage(distance: distance, isOnTopLeft: true)
        }
    }
    
    func showDistanceOnlyInImage(distance: Double?) {
        if let distance = distance {
            addDistanceViewInImage(distance: distance, isOnTopLeft: false)
        }
    }
    
    func show(isDiscarded: Bool, reason: String? = nil) {
        discardedView.isHidden = !isDiscarded
        discardedView.set(reason: reason ?? "")
    }

    // MARK: - Private methods

    // > Sets up the UI
    private func setupUI() {
        cellContent.cornerRadius = LGUIKitConstants.mediumCornerRadius
        
        setupStripArea()
        setupRelatedListingButton()
        setupDiscardedView()
    }
    
    private func setupStripArea() {
        let rotation = CGFloat(Double.pi/4)
        stripeInfoView.transform = CGAffineTransform(rotationAngle: rotation)
        stripeLabel.textColor = UIColor.redText
        // HIDDEN for the moment while we experiment with 3 columns
        stripeInfoView.isHidden = true
        stripeImageView.isHidden = true
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
    
    private func setupProductDetailInImage(price: String, title: String?) {
        featureDetailView.update(with: price, title: title, textStyle: .whiteText)
        layoutProductDetailInImage()
    }
    
    private func addDistanceViewInImage(distance: Double, isOnTopLeft: Bool) {
        addSubviewForAutoLayout(distanceInfoView)
        let distanceString = String(describing: distance) + DistanceType.systemDistanceType().string
        distanceInfoView.setDistance(distanceString)
        let margin = ListingCellMetrics.DistanceView.margin
        if isOnTopLeft {
            distanceInfoView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor,
                                                  constant: margin).isActive = true
        } else {
            distanceInfoView.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor,
                                                     constant: -margin).isActive = true
        }
        distanceInfoView.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor,
                                                  constant: margin).isActive = true
        distanceInfoView.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor,
                                                   constant: -margin).isActive = true
        distanceInfoView.heightAnchor.constraint(equalToConstant: ListingCellMetrics.DistanceView.iconHeight).isActive = true
    }
    
    private func setupDiscardedView() {
        discardedView.editListingCallback = { [weak self] in
            guard let listing = self?.listing else { return }
            self?.delegate?.editPressedForDiscarded(listing: listing)
        }
        discardedView.moreOptionsCallback = { [weak self] in
            guard let listing = self?.listing else { return }
            self?.delegate?.moreOptionsPressedForDiscarded(listing: listing)
        }
        addSubview(discardedView)
        discardedView.layout(with: contentView).fill()
    }
    
    private func layoutFeatureListArea(isMine: Bool, hideProductDetail: Bool) {
        featuredListingInfoView.translatesAutoresizingMaskIntoConstraints = false
        if hideProductDetail {
            showChatButton(isMine: isMine)
        } else {
            showDetailAndChatButton(isMine: isMine)
        }
    }
    
    private func layoutProductDetailInImage() {
        addSubviewForAutoLayout(featureDetailView)
        featureDetailView.layout(with: thumbnailImageView).left().right().bottom(by: 3.0)
    }
    
    private func showChatButton(isMine: Bool) {
        featuredListingInfoView.addSubviewsForAutoLayout([featuredListingChatButton])
        layoutChatButton(isMine: isMine, isUnderProductDetail: false)
    }
    
    private func showDetailAndChatButton(isMine: Bool) {
        featuredListingInfoView.addSubviewsForAutoLayout([featureDetailView,
                                                        featuredListingChatButton])

        featureDetailView.layout(with: featuredListingInfoView).top().left().right()
        layoutChatButton(under: featureDetailView, isMine: isMine, isUnderProductDetail: true)
    }
    
    private func showDetail() {
        featuredListingInfoView.translatesAutoresizingMaskIntoConstraints = false
        featuredListingInfoView.addSubviewsForAutoLayout([featureDetailView])
        featureDetailView.layout(with: featuredListingInfoView).top().leading().trailing().bottom()
    }
    
    private func layoutChatButton(under view: UIView? = nil, isMine: Bool, isUnderProductDetail: Bool) {
        let buttonTopMargin = isMine || isUnderProductDetail ? 0.0 : ListingCellMetrics.ActionButton.topMargin
        let buttonHeight = isMine ? 0.0 : ListingCellMetrics.ActionButton.height
        
        featuredListingChatButton.layout().height(buttonHeight)
        featuredListingChatButton.layout(with: featuredListingInfoView)
            .left(by: ListingCellMetrics.sideMargin)
            .right(by: -ListingCellMetrics.sideMargin)
            .bottom(by: -ListingCellMetrics.ActionButton.bottomMargin)
        if let view = view {
            featuredListingChatButton.layout(with: view).below(by: buttonTopMargin)
        } else {
            featuredListingChatButton.layout(with: featuredListingInfoView).top(by: buttonTopMargin)
        }
    }
    
    // Setup FeatureListingChatButton with feature flags
    private func setupFeaturedListingChatButton() {
        let featureFlags = FeatureFlags.sharedInstance
        if featureFlags.shouldChangeChatNowCopy {
            featuredListingChatButton.setTitle(featureFlags.copyForChatNowInTurkey.variantString,
                                               for: .normal)
        } else {
            featuredListingChatButton.setTitle(LGLocalizedString.bumpUpProductCellChatNowButton,
                                               for: .normal)
        }
        featuredListingChatButton.addTarget(self, action: #selector(openChat), for: .touchUpInside)
    }

    // > Resets the UI to the initial state
    private func resetUI() {
        setupBackgroundColor(id: nil)
        thumbnailImageView.image = nil
        stripeImageView.image = nil
        stripeLabel.text = ""
        stripeIcon.image = nil
        featureDetailView.clearLabelTexts()

        self.delegate = nil
        self.listing = nil

        for featuredInfoSubview in featuredListingInfoView.subviews {
            featuredInfoSubview.removeFromSuperview()
        }

        relatedListingButton.compress()
    }

    // > Accessibility Ids
    private func setAccessibilityIds() {
        thumbnailImageView.set(accessibilityId: .listingCellThumbnailImageView)
        stripeImageView.set(accessibilityId: .listingCellStripeImageView)
        stripeLabel.set(accessibilityId: .listingCellStripeLabel)
        stripeIcon.set(accessibilityId: .listingCellStripeIcon)
        featuredListingChatButton.set(accessibilityId: .listingCellFeaturedChatButton)
    }
    
    
    // MARK: Actions
    
    @objc private func openChat() {
        guard let listing = listing else { return }
        delegate?.chatButtonPressedFor(listing: listing)
    }
    
    // MARK: RoundButtonDelegate
    
    func roundedButtonActionDidTrigger(_ button: RoundButton) {
        guard let listing = self.listing else { return }
        self.delegate?.relatedButtonPressedFor(listing: listing)
    }
}
