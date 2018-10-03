import Foundation
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa

private enum Map {
    static let snapshotSize = CGSize(width: 300, height: 500)
}

private enum Layout {
    static let mapHeight: CGFloat = 115
    static let scrollBottomInset: CGFloat = 3*Metrics.bigMargin
    static let galleryHeight: CGFloat = 220
    enum AttributeGrid {
        static let height: CGFloat = 150
    }
}

final class ListingDetailView: UIView {
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .white
        if #available(iOS 11.0, *) {
            scroll.contentInsetAdjustmentBehavior = .never
        }
        return scroll
    }()

    var pageControlTop: NSLayoutConstraint?
    private let pageControl = ListingCardPageControl()

    private let mediaView: PhotoMediaViewerView
    private var mediaViewModel: PhotoMediaViewerViewModel?
    private var carousel = ListingCardMediaCarousel(media: [], currentIndex: 0)

    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView.vertical([titleLabel, priceLabel])
        stackView.distribution = .fillProportionally
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero
        stackView.spacing = 0
        return stackView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.deckTitleFont
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .white
        return label
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.deckPriceFont
        label.textAlignment = .left
        label.numberOfLines = 1
        label.backgroundColor = .white
        return label
    }()

    private let detailLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.font = UIFont.deckDetailFont
        lbl.textAlignment = .left
        lbl.textColor = UIColor.grayDisclaimerText
        lbl.backgroundColor = .white
        lbl.setContentCompressionResistancePriority(.required, for: .vertical)
        return lbl
    }()

    private let attributeGridView = ListingCarouselMoreInfoViewAttributeGridView(frame: .zero)
    private var attributeGridHeight: NSLayoutConstraint?

    private var tagCollectionViewModel = TagCollectionViewModel(cellStyle: .grayBorder)
    private lazy var tagCollectionView: TagCollectionView = {
        let tagCollectionView = TagCollectionView(viewModel: tagCollectionViewModel, flowLayout: .leftAligned)
        tagCollectionView.register(type: TagCollectionViewCell.self)
        tagCollectionView.defaultSetup()
        return tagCollectionView
    }()

    private let statsView: ListingStatsView = {
        let view = ListingStatsView.make(withStyle: .light)!
        view.timePostedView.layer.borderColor = UIColor.grayLight.cgColor
        view.timePostedView.layer.borderWidth = 1.0
        view.backgroundColor = UIColor.white
        return view
    }()
    private var locationToStats: NSLayoutConstraint?
    private var locationToDetail: NSLayoutConstraint?

    private let userView: UserView = {
        let view = UserView.userView(.full)
        view.showShadow(false)
        return view
    }()
    fileprivate let userTapRelay = PublishRelay<Void>()
    fileprivate let attributesRelay = PublishRelay<Void>()

    private let detailMapView = ListingCardDetailMapView()
    fileprivate let mapTap = UITapGestureRecognizer()

    private let bannerContainer: UIView = UIView()
    lazy var bannerContainerHeight: NSLayoutConstraint = NSLayoutConstraint(item: bannerContainer,
                                                                            attribute: .height,
                                                                            relatedBy: .equal,
                                                                            toItem: nil,
                                                                            attribute: .notAnAttribute,
                                                                            multiplier: 1,
                                                                            constant: 0)
    private var bannerContainerViewLeftConstraint: NSLayoutConstraint?
    private var bannerContainerViewRightConstraint: NSLayoutConstraint?
    private var bannerContainerToBottom: NSLayoutConstraint?
    private var bannerContainerToSocialView: NSLayoutConstraint?


    private let socialMediaHeader: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.white
        label.font = UIFont.deckSocialHeaderFont
        label.textAlignment = .left
        label.text = R.Strings.productShareTitleLabel
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private let socialShareView: SocialShareView = {
        let view = SocialShareView()
        view.style = .grid
        view.gridColumns = 4
        return view
    }()

    private let whiteBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        return view
    }()

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }

    override init(frame: CGRect) {
        self.mediaView = PhotoMediaViewerView(frame: CGRect(origin: frame.origin,
                                                            size: CGSize(width: frame.width, height: Layout.galleryHeight)))
        super.init(frame: frame)
        setupUI()
    }

    func set(socialSharer: SocialSharer?, socialMessage: SocialMessage?, socialDelegate: SocialShareViewDelegate) {
        socialShareView.delegate = socialDelegate
        socialShareView.socialMessage = socialMessage
        socialShareView.socialSharer = socialSharer
    }

    private func setupUI() {
        userView.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapGallery))
        mediaView.addGestureRecognizer(tap)

        detailMapView.addGestureRecognizer(mapTap)

        addSubviewsForAutoLayout([scrollView])
        scrollView.addSubviewsForAutoLayout([mediaView, pageControl, headerStackView, detailLabel,
                                             attributeGridView, tagCollectionView,
                                             statsView, userView, detailMapView, bannerContainer,
                                             socialMediaHeader, socialShareView, whiteBackground])

        let pageControlTop = pageControl.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Metrics.margin)

        let bannerLeft = bannerContainer.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Metrics.shortMargin)
        let bannerRight = bannerContainer.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Metrics.shortMargin)

        let attributeGridHeight = attributeGridView.heightAnchor.constraint(equalToConstant: Layout.AttributeGrid.height)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            pageControlTop,
            pageControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.margin),
            pageControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.margin),

            mediaView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
            mediaView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mediaView.centerXAnchor.constraint(equalTo: centerXAnchor),

            headerStackView.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: Metrics.bigMargin),
            headerStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Metrics.bigMargin),
            headerStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Metrics.bigMargin),

            detailLabel.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: Metrics.shortMargin),
            detailLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Metrics.bigMargin),
            detailLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Metrics.bigMargin),

            attributeGridView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Metrics.bigMargin),
            attributeGridView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Metrics.bigMargin),
            attributeGridHeight,
            attributeGridView.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: Metrics.margin),

            tagCollectionView.topAnchor.constraint(equalTo: attributeGridView.bottomAnchor, constant: Metrics.margin),
            tagCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Metrics.bigMargin),
            tagCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Metrics.bigMargin),

            statsView.topAnchor.constraint(equalTo: tagCollectionView.bottomAnchor, constant: 2*Metrics.margin),
            statsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Metrics.bigMargin),
            statsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Metrics.bigMargin),

            userView.topAnchor.constraint(equalTo: statsView.bottomAnchor, constant: 2*Metrics.margin),
            userView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Metrics.bigMargin),
            userView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Metrics.bigMargin),
            userView.heightAnchor.constraint(equalToConstant: 50),

            detailMapView.topAnchor.constraint(equalTo: userView.bottomAnchor, constant: 2*Metrics.bigMargin),
            detailMapView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.shortMargin),
            detailMapView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.shortMargin),
            detailMapView.heightAnchor.constraint(equalToConstant: Layout.mapHeight),

            bannerContainer.topAnchor.constraint(equalTo: detailMapView.bottomAnchor, constant: 2*Metrics.margin),
            bannerContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            bannerLeft,
            bannerRight,
            bannerContainerHeight,

            socialMediaHeader.topAnchor.constraint(equalTo: bannerContainer.bottomAnchor, constant: 2*Metrics.margin),
            socialMediaHeader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.bigMargin),
            socialMediaHeader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.bigMargin),

            socialShareView.topAnchor.constraint(equalTo: socialMediaHeader.bottomAnchor),
            socialShareView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.shortMargin),
            socialShareView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.shortMargin),
            socialShareView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor,
                                                    constant: -Layout.scrollBottomInset)
            ])

        bannerContainerViewLeftConstraint = bannerLeft
        bannerContainerViewRightConstraint = bannerRight
        self.pageControlTop = pageControlTop
        self.attributeGridHeight = attributeGridHeight
    }

    func setupAttributeGridView(withTitle title: String?,
                                items: [ListingAttributeGridItem]?) {
        guard let items = items, items.count > 0 else {
            attributeGridHeight?.constant = 0.0
            return
        }

        attributeGridHeight?.constant = Layout.AttributeGrid.height
        attributeGridView.setup(withTitle: title,
                                items: items,
                                tapAction: { [weak self] in
                                   self?.attributesRelay.accept(())
        }, theme: .light)
    }

    func populateWith(tags: [String]?) {
        tagCollectionViewModel.tags = tags ?? []
        tagCollectionView.reloadData()

        if (UICollectionView.isIOSBuggyVersion()) {
            tagCollectionView.collectionViewLayout.invalidateLayout()
            tagCollectionView.layoutIfNeeded()
        }
    }

    func populateWith(productInfo: ListingVMProductInfo?, showExactLocationOnMap: Bool) {
        guard let info = productInfo else { return }
        if let location = info.location {
            detailMapView.setLocation(location,
                                      size: Map.snapshotSize,
                                      showExactLocationOnMap: showExactLocationOnMap)
        }
        titleLabel.text = info.title
        titleLabel.isHidden = info.title == nil
        priceLabel.text = info.price

        detailLabel.attributedText = info.description?.stringByRemovingLinks
        detailMapView.setLocationName(info.address)
        setNeedsLayout()
    }

    func populateWith(socialSharer: SocialSharer) {
        socialShareView.socialSharer = socialSharer
    }

    func populateWith(socialMessage: SocialMessage?) {
        socialShareView.socialMessage = socialMessage
        enableSocialView(socialMessage != nil)
        setNeedsLayout()
    }

    func setStatsViewActive(_ active: Bool) {
        locationToStats?.isActive = active
        locationToDetail?.isActive = !active
        setNeedsLayout()
    }

    func addBanner(banner: UIView) {
        bannerContainer.addSubviewForAutoLayout(banner)
        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: bannerContainer.topAnchor),
            banner.bottomAnchor.constraint(equalTo: bannerContainer.bottomAnchor),
            banner.leadingAnchor.constraint(greaterThanOrEqualTo: bannerContainer.leadingAnchor),
            banner.trailingAnchor.constraint(lessThanOrEqualTo: bannerContainer.trailingAnchor),
            banner.centerXAnchor.constraint(equalTo: bannerContainer.centerXAnchor)
        ])
    }

    func updateBannerContainerWith(height: CGFloat, leftMargin: CGFloat, rightMargin: CGFloat) {
        bannerContainerHeight.constant = height
        bannerContainerViewLeftConstraint?.constant = leftMargin
        bannerContainerViewRightConstraint?.constant = rightMargin
    }

    func hideBanner() {
        updateBannerContainerWith(height: 0, leftMargin: 0, rightMargin: 0)
    }

    func bannerAbsolutePosition() -> CGPoint {
        return scrollView.convert(bannerContainer.frame.origin, to: nil)
    }

    func updateBottomInset(_ inset: CGFloat) {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
        scrollView.setNeedsLayout()
    }

    private func enableSocialView(_ enabled: Bool) {
        socialShareView.isHidden = !enabled
        socialMediaHeader.isHidden = !enabled
        bannerContainerToBottom?.isActive = !enabled
        bannerContainerToSocialView?.isActive = enabled
        setNeedsLayout()
    }

    @objc private func didTapGallery(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        let isLeft = location.x / self.width < 0.5
        if isLeft {
            updateWith(carousel: carousel.makePrevious())
        } else {
            updateWith(carousel: carousel.makeNext())
        }
    }
}

extension ListingDetailView: UserViewDelegate {
    func userViewAvatarPressed(_ userView: UserView) {
        userTapRelay.accept(())
    }
    func userViewAvatarLongPressStarted(_ userView: UserView) {}
    func userViewAvatarLongPressEnded(_ userView: UserView) {}
    func userViewTextInfoContainerPressed(_ userView: UserView) {}
}

extension Reactive where Base: ListingDetailView {
    var map: ControlEvent<UITapGestureRecognizer> { return base.mapTap.rx.event }
    var userTap: Driver<Void> { return base.userTapRelay.asDriver(onErrorJustReturn: ()) }
    var attributesTap: Driver<Void> { return base.attributesRelay.asDriver(onErrorJustReturn: ()) }
}

extension ListingDetailView {
    func populateWith(media: [Media], currentIndex: Int) {
        let carousel = ListingCardMediaCarousel(media: media, currentIndex: currentIndex)
        let vm = PhotoMediaViewerViewModel(tag: 0,
                                           media: carousel.media,
                                           backgroundColor: .white,
                                           placeholderImage: nil,
                                           imageDownloader: ImageDownloader.sharedInstance)
        mediaViewModel = vm
        mediaView.set(viewModel: vm)
        mediaView.reloadData()

        updateWith(carousel: carousel)
    }

    private func updateWith(carousel: ListingCardMediaCarousel) {
        pageControl.isHidden = carousel.media.count <= 1

        pageControl.setPages(carousel.media.count)
        pageControl.turnOnAt(carousel.currentIndex)
        self.carousel = carousel

        mediaViewModel?.setIndex(carousel.currentIndex)
    }

    func populateWith(title: String?) {
        titleLabel.text = title
    }

    func populateWith(price: String?) {
        priceLabel.text = price
    }

    func populateWith(detail: String?) {
        detailLabel.text = detail
    }

    func populateWith(stats: ListingDetailStats?) {
        guard let stats = stats, let date = stats.posted else {
            // TODO: collapse
            return
        }
        statsView.updateStatsWithInfo(stats.views ?? 0,
                                      favouritesCount: stats.favs ?? 0,
                                      postedDate: date)
    }

    func populateWith(userDetail: UserDetail) {
        let userInfo = userDetail.userInfo
        let isPro = userDetail.isPro
        userView.setupWith(userAvatar: userInfo.avatar,
                           userName: userInfo.name,
                           productTitle: nil,
                           productPrice: nil,
                           productPaymentFrequency: nil,
                           userId: userInfo.userId,
                           isProfessional: isPro,
                           userBadge: userInfo.badge)
        userView.titleLabel.text = userInfo.name
    }

    func populateWith(location: ListingDetailLocation?) {
        guard let coordinates = location?.location else { return }
        detailMapView.setLocation(coordinates,
                                  size: Map.snapshotSize,
                                  showExactLocationOnMap: location?.showExactLocation ?? false)
        detailMapView.setLocationName(location?.address)
    }
}
