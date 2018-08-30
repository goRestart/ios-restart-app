import UIKit
import LGCoreKit
import LGComponents

private struct InterestedLayout {
    static let width: CGFloat = 54
    static let edges = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: Metrics.veryShortMargin)
}

class FeedListingCell: UICollectionViewCell {
    
    // Subviews
    
    let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.set(accessibilityId: .listingCellThumbnailImageView)
        return iv
    }() // It is public so as to be used in FeedDetailedListingCell for autolayout
    
    private let thumbnailGifImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.set(accessibilityId: .listingCellThumbnailImageView)
        return iv
    }()
    
    private let ribbonView = LGRibbonView()
    
    private let interestedButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: .white)
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        return indicator
    }()
    
    private var thumbnailImageViewHeight: NSLayoutConstraint?
    internal var feedListingData: FeedListingData?
    
    weak var delegate: ProductListingDelegate?
    weak var embeddedInterestedActionDelegate: EmbeddedInterestedActionDelegate?

    var thumbnailImage: UIImage? {
        return thumbnailImageView.image ?? thumbnailGifImageView.currentImage
    }
    
    // MARK:- LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupSelectors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.8 : 1.0
        }
    }
    
    
    // MARK:- Open methods

    func setupUI() {
        cornerRadius = LGUIKitConstants.mediumCornerRadius
        contentView.addSubviewsForAutoLayout([thumbnailImageView, thumbnailGifImageView, ribbonView, interestedButton, activityIndicator])
    }
    
    func resetUI() {
        contentView.backgroundColor = UIColor.placeholderBackgroundColor(nil)
        thumbnailGifImageView.clear()
        ribbonView.clear()
        ribbonView.isHidden = false
        thumbnailImageView.image = nil
        interestedButton.setImage(nil, for: .normal)
    }
    
    func setupConstraints() {
        thumbnailImageView.layout(with: contentView).top().leading().trailing()
        thumbnailImageViewHeight = thumbnailImageView.heightAnchor.constraint(equalToConstant: ListingCellMetrics.thumbnailImageStartingHeight)
        thumbnailImageViewHeight?.priority = .required - 1
        thumbnailImageViewHeight?.isActive = true
        
        thumbnailGifImageView.layout(with: thumbnailImageView).fill()
        
        ribbonView.layout()
            .width(70)
            .widthProportionalToHeight()
        ribbonView.layout(with: contentView)
            .trailing(by: 2)
            .top(by: -2)
        
        interestedButton.layout(with: contentView).trailing(by: InterestedLayout.edges.right)
        interestedButton.layout(with: thumbnailImageView).bottom(by: InterestedLayout.edges.bottom)
        interestedButton.layout().width(InterestedLayout.width).widthProportionalToHeight()
        
        activityIndicator.layout(with: thumbnailImageView).center()
    }
    
    func setupFeedListingData(_ data: FeedListingData) {
        self.feedListingData = data
        contentView.backgroundColor = UIColor.placeholderBackgroundColor(data.listingId)
        setupThumbnail()
        setupRibbon()
        updateInterestedButton(withState: data.interestedState)
        setupActivityIndicator()
    }
    
    private func updateInterestedButton(withState state: InterestedState) {
        interestedButton.setImage(state.image, for: .normal)
        interestedButton.isUserInteractionEnabled = (state != .none && state != .send(enabled: false))
    }
    
    
    // MARK:- Private methods

    private func setupRibbon() {
        guard let model = feedListingData else { return }

        if model.isFree  {
            let ribbonConfiguration = LGRibbonConfiguration(title: R.Strings.productFreePrice,
                                                            icon: R.Asset.IconsButtons.icHeart.image,
                                                            titleColor: .primaryColor)
            ribbonView.setupRibbon(configuration: ribbonConfiguration)
        } else if model.isFeatured {
            let ribbonConfiguration = LGRibbonConfiguration(title: R.Strings.bumpUpProductCellFeaturedStripe,
                                                        icon: nil, titleColor: UIColor.black)
            ribbonView.setupRibbon(configuration: ribbonConfiguration)
        } else {
            ribbonView.isHidden = true
        }
        
    }
    
    private func setupThumbnail() {
        guard let feedListingData = feedListingData else { return }
        thumbnailImageViewHeight?.constant = feedListingData.imageHasFixedSize ? contentView.frame.height : feedListingData.imageSize.height
        
        if feedListingData.mediaThumbType == .video,
            let thumbURL = feedListingData.mediaThumbUrl {
            thumbnailGifImageView.setGifFromURL(thumbURL, showLoader: false)
        } else if let thumbURL = feedListingData.thumbUrl {
            thumbnailImageView.lg_setImageWithURL(thumbURL, placeholderImage: nil, completion: {
                [weak self] (result, url) -> Void in
                if let (_, cached) = result.value, !cached {
                    self?.thumbnailImageView.alpha = 0
                    UIView.animate(withDuration: 0.4, animations: { self?.thumbnailImageView.alpha = 1 })
                }
            })
        }
    }
    
    private func setupSelectors() {
        interestedButton.addTarget(self, action: #selector(interestedButtonTapped(sender:)), for: .touchUpInside)
    }
    
    private func setupActivityIndicator() {
        activityIndicator.isHidden = true
    }
}

// MARK: - Actions

extension FeedListingCell {
    
    @objc private func interestedButtonTapped(sender: UIButton) {
        guard let feedListingData = feedListingData else { return }
        let listing = feedListingData.listing
        let touchPoint = sender.convert(CGPoint.zero, to: nil)
        updateInterestedButton(withState: .send(enabled: false))
        guard feedListingData.preventMessageToProUsers else {
            return interestActionFor(listing: listing, userListing: nil, touchPoint: touchPoint)
        }
        
        guard feedListingData.user.type == .unknown else {
            return interestActionFor(listing: listing,
                                     userListing: LocalUser(userListing: feedListingData.user),
                                     touchPoint: touchPoint)

        }
        
        interestedButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        delegate?.getUserInfoFor(listing) { [weak self] user in
            self?.interestedButton.isHidden = false
            self?.activityIndicator.stopAnimating()
            self?.interestActionFor(listing: listing,
                                    userListing: LocalUser(userListing: feedListingData.user),
                                    touchPoint: touchPoint)
        }
    }
    
    private func interestActionFor(listing: Listing, userListing: LocalUser?, touchPoint: CGPoint) {
        guard let embededInterestedDelegate = embeddedInterestedActionDelegate else {
            delegate?.interestedActionFor(listing,
                                          userListing: userListing,
                                          sectionedFeedChatTrackingInfo: nil) { [weak self] state in
                                            self?.updateInterestedButton(withState: state)
            }
            return
        }
        
        embededInterestedDelegate.interestedActionFor(listing,
                                                      userListing: userListing,
                                                      touchPoint: touchPoint) { [weak self] state in
                                                        self?.updateInterestedButton(withState: state)
        }
    }
}
