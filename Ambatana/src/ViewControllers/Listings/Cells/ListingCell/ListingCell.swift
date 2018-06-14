 import UIKit
import LGCoreKit
import SwiftyGif
import LGComponents

private struct InterestedLayout {
    static let width: CGFloat = 54
    static let edges = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: Metrics.veryShortMargin)
}

protocol ListingCellDelegate: class {
    func chatButtonPressedFor(listing: Listing)
    func editPressedForDiscarded(listing: Listing)
    func moreOptionsPressedForDiscarded(listing: Listing)
    func postNowButtonPressed(_ view: UIView)
    func interestedActionFor(_ listing: Listing)
    func openAskPhoneFor(_ listing: Listing, interlocutor: User)
    func getUserInfoFor(_ listing: Listing, completion: @escaping (User?) -> Void)
}

final class ListingCell: UICollectionViewCell, ReusableCell {
    
    private lazy var interestedButton: UIButton = UIButton()
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .white)
    // > Stripe area
    
    private let stripeImageView = UIImageView()
    private let stripeInfoView = UIView()
    private let stripeInfoInnerContainerView = UIView()
    
    private let stripeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemMediumFont(size: 12)
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let stripeIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    // > Thumbnail Image and background
    
    private let thumbnailBgColorView = UIView()
    private let thumbnailImageView = UIImageView()
    private let thumbnailGifImageView = UIImageView()
    
    // > Product Detail related Views
    
    private let featuredListingInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
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
    
    // > Distance Labels
    
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
    
    // > Discarded Views
    
    private let discardedView: DiscardedView = {
        let view = DiscardedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private var detailViewInImageHeightConstraints: NSLayoutConstraint?
    private var thumbnailImageViewHeight: NSLayoutConstraint?
    private var stripeIconWidth: NSLayoutConstraint?
    
    var listing: Listing?
    weak var delegate: ListingCellDelegate?
    
    var likeButtonEnabled: Bool = true
    var chatButtonEnabled: Bool = true
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.8 : 1.0
        }
    }
    
    var thumbnailImage: UIImage? {
        let image: UIImage?
        if thumbnailImageView.image != nil {
            image = thumbnailImageView.image
        } else {
            image = thumbnailGifImageView.currentImage
        }
        return image
    }
    
    // MARK:- Lifecycle
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        cornerRadius = LGUIKitConstants.mediumCornerRadius
        resetUI()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    // MARK: - Public / internal methods
    
    func setupBackgroundColor(id: String?) {
        thumbnailBgColorView.backgroundColor = UIColor.placeholderBackgroundColor(id)
    }
    
    func setupImageUrl(_ imageUrl: URL, imageSize: CGSize, preventMessagesToPro: Bool) {
        thumbnailImageViewHeight?.constant = imageSize.height
        thumbnailImageView.lg_setImageWithURL(imageUrl, placeholderImage: nil, completion: {
            [weak self] (result, url) -> Void in
            if let (_, cached) = result.value, !cached {
                self?.thumbnailImageView.alpha = 0
                UIView.animate(withDuration: 0.4, animations: { self?.thumbnailImageView.alpha = 1 })
            }
        })
        setupInterestedButton(inside: thumbnailImageView, preventMessagesToPro: preventMessagesToPro)
    }
    
    func setupGifUrl(_ imageUrl: URL, imageSize: CGSize, preventMessagesToPro: Bool) {
        thumbnailImageViewHeight?.constant = imageSize.height
        thumbnailGifImageView.setGifFromURL(imageUrl, showLoader: false)
        
        guard interestedButton.superview != thumbnailGifImageView else { return }
        interestedButton.removeFromSuperview()
        setupInterestedButton(inside: thumbnailGifImageView, preventMessagesToPro: preventMessagesToPro)
    }
    
    private func setupInterestedButton(inside view: UIView, preventMessagesToPro: Bool) {
        guard interestedButton.superview != view else { return }
        interestedButton.removeFromSuperview()
        view.addSubviewForAutoLayout(interestedButton)
        view.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            interestedButton.rightAnchor.constraint(equalTo: view.rightAnchor,
                                                    constant: InterestedLayout.edges.right),
            interestedButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                     constant: InterestedLayout.edges.bottom),
            interestedButton.heightAnchor.constraint(equalTo: interestedButton.widthAnchor),
            interestedButton.widthAnchor.constraint(equalToConstant: InterestedLayout.width)
        ])
        interestedButton.removeTarget(self, action: nil, for: .allEvents)
        interestedButton.addTarget(self, action: #selector(callDelegateInterestedState), for: .touchUpInside)
        setupActivityIndicator(inside: view, preventMessagesToPro: preventMessagesToPro)
    }
    
    private func setupActivityIndicator(inside view: UIView, preventMessagesToPro: Bool) {
        guard preventMessagesToPro else { return }
        activityIndicator.hidesWhenStopped = true
        activityIndicator.removeFromSuperview()
        view.addSubviewForAutoLayout(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: interestedButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: interestedButton.centerYAnchor)
            ])
    }
    
    func setupFreeStripe() {
        stripeIconWidth?.constant = ListingCellMetrics.stripeIconWidth
        stripeImageView.image = R.Asset.BackgroundsAndImages.stripeWhite.image
        stripeIcon.image = R.Asset.IconsButtons.icHeart.image
        stripeLabel.text = R.Strings.productFreePrice
        stripeLabel.textColor = UIColor.primaryColor
        stripeImageView.isHidden = false
        stripeInfoView.isHidden = false
    }
    
    func setupFeaturedStripe(withTextColor textColor: UIColor) {
        stripeIconWidth?.constant = 0
        stripeImageView.image = R.Asset.BackgroundsAndImages.stripeWhite.image
        stripeIcon.image = nil
        stripeLabel.text = R.Strings.bumpUpProductCellFeaturedStripe
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
        if !discardedView.isHidden {
            hideDistanceAndDetailViews()
        }
    }
    
    
    // MARK: - Private methods
    
    // > Sets up UI
    private func setupUI() {
        contentView.addSubviewsForAutoLayout([thumbnailBgColorView,
                                              thumbnailImageView,
                                              thumbnailGifImageView,
                                              featuredListingInfoView,
                                              stripeImageView, stripeInfoView,
                                              discardedView,
                                              topDistanceInfoView, bottomDistanceInfoView,
                                              detailViewInImage])
        setupThumbnailImageViews()
        setupFeaturedListingInfoView()
        setupStripArea()
        setupDiscardedView()
        setupDistanceLabels()
        setupDetailViewInImage()
    }
    
    private func setupDetailViewInImage() {
        detailViewInImage.layout(with: thumbnailImageView)
            .fillHorizontal()
            .bottom()
        detailViewInImageHeightConstraints = detailViewInImage.heightAnchor.constraint(equalToConstant: contentView.height)
        detailViewInImageHeightConstraints?.isActive = true
    }
    
    private func setupThumbnailImageViews() {
        setupThumbnailImageViewUI()
        setupThumbnialImageViewConstraints()
    }
    
    private func setupThumbnailImageViewUI() {
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailGifImageView.clipsToBounds = true
        thumbnailGifImageView.contentMode = .scaleAspectFill
    }
    
    private func setupThumbnialImageViewConstraints() {
        thumbnailImageView.layout(with: contentView).top().leading().trailing()
        thumbnailImageViewHeight = thumbnailImageView.heightAnchor.constraint(equalToConstant: ListingCellMetrics.thumbnailImageStartingHeight)
        thumbnailImageViewHeight?.isActive = true
        thumbnailBgColorView.layout(with: thumbnailImageView).fill()
        thumbnailGifImageView.layout(with: thumbnailImageView).fill()
    }
    
    private func setupFeaturedListingInfoView() {
        featuredListingInfoView.layout(with: contentView).bottom().leading().trailing()
        featuredListingInfoView.layout(with: thumbnailImageView).below()
    }
    
    private func setupStripArea() {
        layoutStripArea()
        let rotation = CGFloat(Double.pi/4)
        stripeInfoView.transform = CGAffineTransform(rotationAngle: rotation)
        stripeLabel.textColor = UIColor.redText
        
        stripeInfoView.isHidden = true
        stripeImageView.isHidden = true
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
        discardedView.layout(with: contentView).fill()
    }
    
    private func setupDistanceLabels() {
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
    
    private func layoutStripArea() {
        NSLayoutConstraint.activate([
            stripeImageView.widthAnchor.constraint(equalToConstant: 70),
            stripeImageView.heightAnchor.constraint(equalToConstant: 70),
            stripeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 2),
            stripeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -2),
            
            stripeInfoView.widthAnchor.constraint(equalToConstant: 63),
            stripeInfoView.heightAnchor.constraint(equalToConstant: 24),
            stripeInfoView.leadingAnchor.constraint(equalTo: stripeImageView.leadingAnchor, constant: 16),
            stripeInfoView.centerYAnchor.constraint(equalTo: stripeImageView.centerYAnchor, constant: -7)
            ])
        setupStripInfoView()
    }
    
    private func setupStripInfoView() {
        stripeInfoView.addSubviewForAutoLayout(stripeInfoInnerContainerView)
        NSLayoutConstraint.activate([
            stripeInfoInnerContainerView.centerXAnchor.constraint(equalTo: stripeInfoView.centerXAnchor, constant: 2),
            stripeInfoInnerContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: stripeInfoView.leadingAnchor),
            stripeInfoInnerContainerView.trailingAnchor.constraint(greaterThanOrEqualTo: stripeInfoView.trailingAnchor),
            stripeInfoInnerContainerView.bottomAnchor.constraint(equalTo: stripeInfoView.bottomAnchor),
            stripeInfoInnerContainerView.topAnchor.constraint(equalTo: stripeInfoView.topAnchor)
            ])
        setupStripeInfoContainerSubviews()
    }
    
    private func setupStripeInfoContainerSubviews() {
        stripeInfoInnerContainerView.addSubviewsForAutoLayout([stripeLabel, stripeIcon])
        
        NSLayoutConstraint.activate([
            stripeLabel.trailingAnchor.constraint(equalTo: stripeInfoInnerContainerView.trailingAnchor),
            stripeLabel.bottomAnchor.constraint(equalTo: stripeInfoInnerContainerView.bottomAnchor),
            stripeLabel.topAnchor.constraint(equalTo: stripeInfoInnerContainerView.topAnchor),
            stripeLabel.heightAnchor.constraint(equalToConstant: 34),
            stripeLabel.leadingAnchor.constraint(equalTo: stripeIcon.trailingAnchor, constant: 3)
            ])
        
        stripeIconWidth = stripeIcon.widthAnchor.constraint(equalToConstant: 14)
        stripeIconWidth?.isActive = true
        NSLayoutConstraint.activate([
            stripeIcon.leadingAnchor.constraint(equalTo: stripeInfoInnerContainerView.leadingAnchor),
            stripeIcon.bottomAnchor.constraint(equalTo: stripeInfoInnerContainerView.bottomAnchor, constant: -Metrics.veryShortMargin),
            stripeIcon.topAnchor.constraint(equalTo: stripeInfoInnerContainerView.topAnchor, constant: Metrics.veryShortMargin)
            ])
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
    
    func setupWith(interestedState action: InterestedState) {
        interestedButton.setImage(action.image, for: .normal)
        interestedButton.imageView?.contentMode = .scaleAspectFit
        interestedButton.imageView?.clipsToBounds = true
        interestedButton.isUserInteractionEnabled = action != .none
    }
    
    @objc private func callDelegateInterestedState() {
        guard let listing = listing else { return }
        let featureFlags = FeatureFlags.sharedInstance
        if featureFlags.preventMessagesFromFeedToProUsers.isActive  {
            interestedButton.isHidden = true
            activityIndicator.startAnimating()
            delegate?.getUserInfoFor(listing, completion: { [weak self] user in
                guard let strongSelf = self else { return }
                strongSelf.interestedButton.isHidden = false
                strongSelf.activityIndicator.stopAnimating()
                if let user = user, user.isProfessional {
                     strongSelf.delegate?.openAskPhoneFor(listing, interlocutor: user)
                } else {
                    strongSelf.delegate?.interestedActionFor(listing)
                }
            })
        } else {
            delegate?.interestedActionFor(listing)
        }
    }
    
    private func layoutFeatureListArea(isMine: Bool, hideProductDetail: Bool) {
        if hideProductDetail {
            showChatButton(isMine: isMine)
        } else {
            showDetailAndChatButton(isMine: isMine)
        }
    }
    
    private func layoutProductDetailInImage(title: String?) {
        let height = ListingCellMetrics.getTotalHeightForPriceAndTitleView(title, containerWidth: contentView.width)
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
        if featureFlags.shouldChangeChatNowCopyInTurkey {
            featuredListingChatButton.setTitle(featureFlags.copyForChatNowInTurkey.variantString,
                                               for: .normal)
        } else if featureFlags.shouldChangeChatNowCopyInEnglish {
            featuredListingChatButton.setTitle(featureFlags.copyForChatNowInEnglish.variantString,
                                               for: .normal)
        } else {
            featuredListingChatButton.setTitle(R.Strings.bumpUpProductCellChatNowButton,
                                               for: .normal)
        }
        featuredListingChatButton.addTarget(self, action: #selector(openChat), for: .touchUpInside)
    }
    
    private func hideDistanceAndDetailViews() {
        topDistanceInfoView.isHidden = true
        bottomDistanceInfoView.isHidden = true
        detailViewInImage.isHidden = true
    }
    
    // > Resets the UI to the initial state
    private func resetUI() {
        setupBackgroundColor(id: nil)
        thumbnailGifImageView.clear()
        thumbnailImageView.image = nil
        stripeImageView.image = nil
        stripeLabel.text = ""
        stripeIcon.image = nil
        detailViewInImage.clearLabelTexts()
        topDistanceInfoView.clearAll()
        bottomDistanceInfoView.clearAll()
        setupWith(interestedState: .none)
        
        self.delegate = nil
        self.listing = nil
        
        for featuredInfoSubview in featuredListingInfoView.subviews {
            featuredInfoSubview.removeFromSuperview()
        }
    }
    
    
    // > Accessibility Ids
    private func setAccessibilityIds() {
        thumbnailImageView.set(accessibilityId: .listingCellThumbnailImageView)
        thumbnailGifImageView.set(accessibilityId: .listingCellThumbnailImageView)
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

private extension InterestedState {
    var image: UIImage? {
        switch self {
        case .none: return nil
        case .send(let enabled):
            let alpha: CGFloat = enabled ? 1 : 0.7
            return R.Asset.IconsButtons.IAmInterested.icIamiSend.image.withAlpha(alpha) ?? R.Asset.IconsButtons.IAmInterested.icIamiSend.image
        case .seeConversation: return R.Asset.IconsButtons.IAmInterested.icIamiSeeconv.image
        }
    }
}
