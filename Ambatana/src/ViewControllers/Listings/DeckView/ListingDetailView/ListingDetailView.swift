import Foundation
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa

private enum Images {
    static let favourite = R.Asset.IconsButtons.NewItemPage.nitFavourite.image
    static let favouriteOn = R.Asset.IconsButtons.NewItemPage.nitFavouriteOn.image

    static let edit = R.Asset.IconsButtons.NewItemPage.nitEdit.image
    static let placeholder = R.Asset.IconsButtons.userPlaceholder.image
    static let share = R.Asset.IconsButtons.NewItemPage.nitShare.image
}

private enum Map {
    static let snapshotSize = CGSize(width: 300, height: 500)
}

private enum Layout {
    static let mapHeight: CGFloat = 115
    static let actionButton: CGFloat = 60
    static let scrollBottomInset: CGFloat = Layout.actionButton + 3*Metrics.bigMargin
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

    private let mainImageView: UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.image = R.Asset.BackgroundsAndImages.bg1New.image
        img.contentMode = .scaleAspectFit
        return img
    }()
    private var carousel: ListingCardMediaCarousel?

    private var mainImgHeightConstraint: NSLayoutConstraint?
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

    private let statsView: ListingStatsView = {
        let view = ListingStatsView.make(withStyle: .light)!
        view.timePostedView.layer.borderColor = UIColor.grayLight.cgColor
        view.timePostedView.layer.borderWidth = 1.0
        view.backgroundColor = UIColor.white
        return view
    }()
    private var locationToStats: NSLayoutConstraint?
    private var locationToDetail: NSLayoutConstraint?

    private let userView = ListingCardUserView()

    private let detailMapView = ListingCardDetailMapView()
    fileprivate let mapTap = UITapGestureRecognizer()

    private var mapSnapShotToBottom: NSLayoutConstraint?
    private var mapSnapShotToSocialView: NSLayoutConstraint?

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
    private let actionButton: UIControl = {
        let btn = LetgoButton(withStyle: .primary(fontSize: .big))
        btn.setTitle(R.Strings.listingInterestedButtonA, for: .normal)
        return btn
    }()

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func updateImageViewAspectRatio() {
        guard let size = mainImageView.image?.size else { return }
        mainImgHeightConstraint?.constant = (size.height / size.width) * mainImageView.bounds.width
        setNeedsLayout()
    }

    private func setupUI() {
        detailMapView.addGestureRecognizer(mapTap)

        addSubviewsForAutoLayout([scrollView])
        scrollView.addSubviewsForAutoLayout([mainImageView, pageControl, headerStackView, detailLabel,
                                             statsView, userView, detailMapView, socialMediaHeader,
                                             socialShareView, whiteBackground, actionButton])

        let height = mainImageView.heightAnchor.constraint(equalToConstant: 60) // totally arbitrary
        let pageControlTop = pageControl.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Metrics.margin)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            pageControlTop,
            pageControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.margin),
            pageControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.margin),

            height,
            mainImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mainImageView.centerXAnchor.constraint(equalTo: centerXAnchor),

            headerStackView.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: Metrics.bigMargin),
            headerStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Metrics.bigMargin),
            headerStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Metrics.bigMargin),

            detailLabel.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: Metrics.shortMargin),
            detailLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Metrics.bigMargin),
            detailLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Metrics.bigMargin),

            statsView.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 2*Metrics.margin),
            statsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Metrics.bigMargin),
            statsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Metrics.bigMargin),

            userView.topAnchor.constraint(equalTo: statsView.bottomAnchor, constant: 2*Metrics.margin),
            userView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Metrics.bigMargin),
            userView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Metrics.bigMargin),

            detailMapView.topAnchor.constraint(equalTo: userView.bottomAnchor, constant: 2*Metrics.bigMargin),
            detailMapView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.shortMargin),
            detailMapView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.shortMargin),
            detailMapView.heightAnchor.constraint(equalToConstant: Layout.mapHeight),

            socialMediaHeader.topAnchor.constraint(equalTo: detailMapView.bottomAnchor, constant: 2*Metrics.margin),
            socialMediaHeader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.bigMargin),
            socialMediaHeader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.bigMargin),

            socialShareView.topAnchor.constraint(equalTo: socialMediaHeader.bottomAnchor),
            socialShareView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.shortMargin),
            socialShareView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.shortMargin),
            socialShareView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor,
                                                    constant: -Layout.scrollBottomInset),

            whiteBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            whiteBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            whiteBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            whiteBackground.topAnchor.constraint(equalTo: actionButton.topAnchor, constant: -Metrics.bigMargin),

            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.bigMargin),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.bigMargin),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.bigMargin),
            actionButton.heightAnchor.constraint(equalToConstant: Layout.actionButton)
            ])

        self.mainImgHeightConstraint = height
        self.pageControlTop = pageControlTop
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

    private func enableSocialView(_ enabled: Bool) {
        socialShareView.isHidden = !enabled
        socialMediaHeader.isHidden = !enabled
        mapSnapShotToBottom?.isActive = !enabled
        mapSnapShotToSocialView?.isActive = enabled
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateImageViewAspectRatio()

    }
}

extension Reactive where Base: ListingDetailView {
    var map: ControlEvent<UITapGestureRecognizer> { return base.mapTap.rx.event }
}

extension ListingDetailView {
    func populateWith(media: [Media]) {
        updateWith(carousel: ListingCardMediaCarousel(media: media, current: 0))
    }

    private func updateWith(carousel: ListingCardMediaCarousel) {
        pageControl.setPages(carousel.media.count)
        pageControl.turnOnAt(carousel.current)
        self.carousel = carousel

        guard let url = carousel.media[safeAt: carousel.current]?.outputs.image else { return }
        mainImageView.lg_setImageWithURL(url)
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

    func populateWith(userInfo: ListingVMUserInfo) {
        userView.populate(withUserName: userInfo.name,
                          placeholder: userInfo.avatarPlaceholder(),
                          icon: userInfo.avatar,
                          imageDownloader: ImageDownloader.sharedInstance,
                          badgeType: userInfo.badge)
    }

    func populateWith(location: ListingDetailLocation?) {
        guard let coordinates = location?.location else { return }
        detailMapView.setLocation(coordinates,
                                  size: Map.snapshotSize,
                                  showExactLocationOnMap: location?.showExactLocation ?? false)
        detailMapView.setLocationName(location?.address)
    }
}
