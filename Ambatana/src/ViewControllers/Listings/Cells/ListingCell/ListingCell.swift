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
    func editPressedForDiscarded(listing: Listing)
    func moreOptionsPressedForDiscarded(listing: Listing)
}

final class ListingCell: UICollectionViewCell, ReusableCell {
    
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
    
    private var featureView: ProductPriceAndTitleView?
    
    private let detailViewInImage: ProductPriceAndTitleView = {
        let view = ProductPriceAndTitleView(textStyle: .whiteText)
        view.isHidden = true
        return view
    }()
    
    private let  bottomDistanceInfoView: DistanceInfoView = {
        let view = DistanceInfoView(frame: .zero)
        view.isHidden = true
        return view
    }()

    private let topDistanceInfoView: DistanceInfoView = {
        let view = DistanceInfoView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    private let discardedView: DiscardedView = {
        let view = DiscardedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

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

    // Product Detail Under Image
    func setupFeaturedListingInfoWith(price: String, title: String?, isMine: Bool, hideProductDetail: Bool) {
        featureView = ProductPriceAndTitleView(textStyle: .darkText)
        featureView?.configUI(title: title, price: price, style: hideProductDetail ? .whiteText : .darkText)
        setupFeaturedListingChatButton()
        layoutFeatureListArea(isMine: isMine, hideProductDetail: hideProductDetail)
    }
    
    func setupNonFeaturedProductInfoUnderImage(price: String, title: String?, shouldShow: Bool) {
        if shouldShow {
            featureView = ProductPriceAndTitleView(textStyle: .darkText)
            featureView?.configUI(title: title, price: price, style: .darkText)
            showDetail()
        }
    }
    
    // Product Detail In Image
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
        setupDiscardedView()
        setupDistanceLabels()
        setupDetailViewInImage()
    }
    
    private var detailViewInImageHeightConstraints: NSLayoutConstraint?
    private func setupDetailViewInImage() {
        contentView.addSubviewForAutoLayout(detailViewInImage)
        detailViewInImage.layout(with: thumbnailImageView)
            .fillHorizontal()
            .bottom()
        detailViewInImageHeightConstraints = detailViewInImage.heightAnchor.constraint(equalToConstant: contentView.height)
        detailViewInImageHeightConstraints?.isActive = true
    }
    
    private func setupDistanceLabels() {
        contentView.addSubviewsForAutoLayout([topDistanceInfoView, bottomDistanceInfoView])
        let margin = ListingCellMetrics.DistanceView.margin
        let height = ListingCellMetrics.DistanceView.iconHeight
        topDistanceInfoView.layout(with: thumbnailImageView)
            .fillHorizontal(by: margin)
            .top(by: margin)
        
        bottomDistanceInfoView.layout(with: thumbnailImageView)
            .fillHorizontal(by: margin)
            .bottom(by: -margin)
            
        NSLayoutConstraint.activate([
            topDistanceInfoView.heightAnchor.constraint(equalToConstant: height),
            bottomDistanceInfoView.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    private func setupStripArea() {
        let rotation = CGFloat(Double.pi/4)
        stripeInfoView.transform = CGAffineTransform(rotationAngle: rotation)
        stripeLabel.textColor = UIColor.redText
        // HIDDEN for the moment while we experiment with 3 columns
        stripeInfoView.isHidden = true
        stripeImageView.isHidden = true
    }
    
    private func setupProductDetailInImage(price: String, title: String?) {
        detailViewInImage.configUI(title: title, price: price, style: .whiteText)
        detailViewInImage.isHidden = false
        layoutProductDetailInImage(title: title)
    }
    
    private func addDistanceViewInImage(distance: Double, isOnTopLeft: Bool) {

        let distanceString = String(describing: distance) + DistanceType.systemDistanceType().string
        
        if isOnTopLeft {
            topDistanceInfoView.isHidden = false
            bottomDistanceInfoView.isHidden = true
            topDistanceInfoView.setDistance(distanceString)
        } else {
            topDistanceInfoView.isHidden = true
            bottomDistanceInfoView.isHidden = false
            bottomDistanceInfoView.setDistance(distanceString)
        }
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
        contentView.addSubview(discardedView)
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
    
    private func layoutProductDetailInImage(title: String?) {
        let height = ListingCellMetrics.getTotalHeightForPriceAndTitleView(title, containerWidth: cellContent.width)
        detailViewInImageHeightConstraints?.constant = height
    }
    
    private func showChatButton(isMine: Bool) {
        if !featuredListingInfoView.subviews.contains(featuredListingChatButton) {
            featuredListingInfoView.addSubviewsForAutoLayout([featuredListingChatButton])
        }
        layoutChatButton(isMine: isMine, isUnderProductDetail: false)
    }
    
    private func showDetailAndChatButton(isMine: Bool) {
        guard let featureView = featureView else { return }
        featuredListingInfoView.addSubviewsForAutoLayout([featureView,
                                                        featuredListingChatButton])
        featureView.layout(with: featuredListingInfoView).top().left().right()
        layoutChatButton(under: featureView, isMine: isMine, isUnderProductDetail: true)
    }
    
    private func showDetail() {
        guard let featureView = featureView else { return }
        featuredListingInfoView.translatesAutoresizingMaskIntoConstraints = false
        featuredListingInfoView.addSubviewsForAutoLayout([featureView])
        featureView.layout(with: featuredListingInfoView).top().leading().trailing().bottom()
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
        detailViewInImage.clearLabelTexts()
        topDistanceInfoView.clearAll()
        bottomDistanceInfoView.clearAll()
        
        self.delegate = nil
        self.listing = nil

        for featuredInfoSubview in featuredListingInfoView.subviews {
            featuredInfoSubview.removeFromSuperview()
        }
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
}
