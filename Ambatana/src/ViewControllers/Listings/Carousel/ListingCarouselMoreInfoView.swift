//
//  ListingCarouselMoreInfoView.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import MapKit
import LGCoreKit
import RxSwift
import LGCollapsibleLabel
import GoogleMobileAds

// This might go away if the new design ABIOS-3100 wins
enum MoreInfoState {
    case hidden
    case moving
    case shown
}

protocol ProductCarouselMoreInfoDelegate: class {
    func didEndScrolling(_ topOverScroll: CGFloat, bottomOverScroll: CGFloat)
    func request(fullScreen: Bool)
    func viewControllerToShowShareOptions() -> UIViewController
    func rootViewControllerForDFPBanner() -> UIViewController
}

extension MKMapView {
    // Create a unique isntance of MKMapView due to: http://stackoverflow.com/questions/36417350/mkmapview-using-a-lot-of-memory-each-time-i-load-its-view
    @nonobjc static let sharedInstance = MKMapView()
}

class ListingCarouselMoreInfoView: UIView {

    fileprivate static let relatedItemsHeight: CGFloat = 80
    fileprivate static let shareViewToMapMargin: CGFloat = 30
    fileprivate static let navBarDefaultHeight: CGFloat = 64
    fileprivate static let shareViewToBannerMargin = Metrics.margin
    fileprivate static let dragViewVerticalExtraMargin: CGFloat = 2 // Center purposes to the custom navigation bar in carousel view

    @IBOutlet weak var titleText: UITextView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var autoTitleLabel: UILabel!
    @IBOutlet weak var transTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContent: UIView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var visualEffectViewBottom: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: LGCollapsibleLabel!
    @IBOutlet weak var tagCollectionView: TagCollectionView!
    @IBOutlet weak var statsContainerView: UIView!
    @IBOutlet weak var statsContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statsContainerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dragView: UIView!
    @IBOutlet weak var dragButton: UIView!
    @IBOutlet weak var dragViewTitle: UILabel!
    @IBOutlet weak var dragViewImage: UIImageView!

    fileprivate let mapView: MKMapView = MKMapView.sharedInstance
    fileprivate var vmRegion: MKCoordinateRegion? = nil
    @IBOutlet weak var mapViewContainer: UIView!
    fileprivate var mapViewContainerExpandable: UIView? = nil
    fileprivate var mapViewTapGesture: UITapGestureRecognizer? = nil

    @IBOutlet weak var bannerContainerView: UIView!
    @IBOutlet weak var bannerContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerContainerViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerContainerViewRightConstraint: NSLayoutConstraint!

    @IBOutlet var shareViewToMapTopConstraint: NSLayoutConstraint!
    @IBOutlet var shareViewToBannerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewToSuperviewTopConstraint: NSLayoutConstraint!
    
    var dfpBannerView: DFPBannerView?

    @IBOutlet weak var socialShareContainer: UIView!
    @IBOutlet weak var socialShareTitleLabel: UILabel!
    @IBOutlet weak var socialShareView: SocialShareView!

    fileprivate let disposeBag = DisposeBag()
    fileprivate var locationZone: MKOverlay?
    fileprivate let bigMapMargin: CGFloat = 65
    fileprivate let bigMapBottomMargin: CGFloat = 85
    fileprivate(set) var mapExpanded: Bool = false
    fileprivate var mapZoomBlocker: MapZoomBlocker?
    fileprivate var statsView: ListingStatsView?

    fileprivate let statsContainerViewHeight: CGFloat = 24
    fileprivate let statsContainerViewTop: CGFloat = 26
    fileprivate var initialDragYposition: CGFloat = 0

    weak var viewModel: ListingCarouselViewModel?
    weak var delegate: ProductCarouselMoreInfoDelegate?
    
    fileprivate var tagCollectionViewModel: TagCollectionViewModel?

    static func moreInfoView() -> ListingCarouselMoreInfoView {
        guard let view = Bundle.main.loadNibNamed("ListingCarouselMoreInfoView", owner: self, options: nil)?.first
            as? ListingCarouselMoreInfoView else { return ListingCarouselMoreInfoView() }
        view.setupUI()
        view.setupTagCollectionView()
        view.setupStatsView()
        view.setAccessibilityIds()
        view.addGestures()
        return view
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupWith(viewModel: ListingCarouselViewModel) {
        setupContentRx(viewModel: viewModel)
        setupMapRx(viewModel: viewModel)
        setupStatsRx(viewModel: viewModel)
        setupBottomPanelRx(viewModel: viewModel)
        self.viewModel = viewModel
        if viewModel.adActive {
            setupAdBannerWith(viewModel: viewModel)
        }
    }

    func viewWillShow() {
        setupMapViewIfNeeded()
        if let adActive = viewModel?.adActive, adActive {
            if let adBannerTrackingStatus = viewModel?.adBannerTrackingStatus {
                viewModel?.adAlreadyRequestedWithStatus(adBannerTrackingStatus: adBannerTrackingStatus)
            } else {
                shareViewToMapTopConstraint.isActive = true
                shareViewToBannerTopConstraint.isActive = true
                loadDFPRequest()
            }
        } else {
            hideAdsBanner()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // We need to call invalidateLayout in the CollectionView to fix what appears to be an iOS 10 UIKit bug:
        // https://stackoverflow.com/a/44467194
        tagCollectionView.collectionViewLayout.invalidateLayout()
        mapView.cornerRadius = LGUIKitConstants.bigCornerRadius
        dragButton.setRoundedCorners()
        mapView.cornerRadius = LGUIKitConstants.bigCornerRadius
    }

    func dismissed() {
        scrollView.contentOffset = CGPoint.zero
        descriptionLabel.collapsed = true
    }

    deinit {
        // MapView is a shared instance and all references must be removed
        cleanMapView()
    }

    // MARK: - UI

    func updateBottomAreaMargin(with value: CGFloat) {
        self.scrollViewBottomConstraint.constant = value
    }
}


// MARK: - Gesture Intections 

extension ListingCarouselMoreInfoView {
    func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(compressMap))
        visualEffectView.addGestureRecognizer(tap)
    }
}


// MARK: - MapView stuff

extension ListingCarouselMoreInfoView: MKMapViewDelegate {

    func setupMapViewIfNeeded() {
        let container = mapExpanded ? mapViewContainerExpandable : mapViewContainer
        guard let theContainer = container, mapView.superview != theContainer else { return }
        setupMapView(inside: theContainer)
    }
    
    func setupMapView(inside container: UIView) {
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-SetupMapView-start")
        layoutMapView(inside: container)
        addMapGestures()
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-SetupMapView-end")
    }

    fileprivate func setupMapRx(viewModel: ListingCarouselViewModel) {
        let productLocation = viewModel.productInfo.asObservable().map { $0?.location }.unwrap()
        productLocation.bind { [weak self] coordinate in
            self?.addRegion(with: coordinate, zoomBlocker: true)
            self?.setupMapExpanded(false)
            self?.locationZone = MKCircle(center:coordinate.coordinates2DfromLocation(),
                                    radius: Constants.accurateRegionRadius)
        }.disposed(by: disposeBag)
    }

    private func layoutMapView(inside container: UIView) {
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-LayoutMapView-start")
        if mapView.superview != nil {
            mapView.removeFromSuperview()
        }
        mapView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(mapView)
        container.addConstraint(NSLayoutConstraint(item: mapView, attribute: .left, relatedBy: .equal,
            toItem: container, attribute: .left, multiplier: 1, constant: 0))
        container.addConstraint(NSLayoutConstraint(item: mapView, attribute: .right, relatedBy: .equal,
            toItem: container, attribute: .right, multiplier: 1, constant: 0))
        container.addConstraint(NSLayoutConstraint(item: mapView, attribute: .top, relatedBy: .equal,
            toItem: container, attribute: .top, multiplier: 1, constant: 0))
        container.addConstraint(NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal,
            toItem: container, attribute: .bottom, multiplier: 1, constant: 8))
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-LayoutMapView-end")
    }
    
    private func addMapGestures() {
        removeMapGestures()
        mapViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap))
        guard let mapViewTapGesture = mapViewTapGesture else { return }
        mapView.addGestureRecognizer(mapViewTapGesture)
    }
    
    private func removeMapGestures() {
        mapView.gestureRecognizers?.forEach { mapView.removeGestureRecognizer($0) }
    }
    
    fileprivate func cleanMapView() {
        // Clean only references related to current More Info View
        mapZoomBlocker?.mapView = nil
        if let mapViewTapGesture = mapViewTapGesture, let gestures = mapView.gestureRecognizers, gestures.contains(mapViewTapGesture) {
                mapView.removeGestureRecognizer(mapViewTapGesture)
        }
        if mapView.superview == mapViewContainer || mapView.superview == mapViewContainerExpandable {
            mapView.removeFromSuperview()
        }
    }
    
    @objc func didTapMap() {
        mapExpanded ? compressMap() : expandMap()
    }

    func setupMapExpanded(_ enabled: Bool) {
        mapExpanded = enabled
        mapView.isZoomEnabled = enabled
        mapView.isScrollEnabled = enabled
        mapView.isPitchEnabled = enabled
    }
    
    func addRegion(with coordinate: LGLocationCoordinates2D, zoomBlocker: Bool) {
        let clCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        vmRegion = MKCoordinateRegionMakeWithDistance(clCoordinate, Constants.accurateRegionRadius*2, Constants.accurateRegionRadius*2)
        guard let region = vmRegion else { return }
        mapView.setRegion(region, animated: false)
        
        if zoomBlocker {
            mapZoomBlocker = MapZoomBlocker(mapView: mapView, minLatDelta: region.span.latitudeDelta,
                                            minLonDelta: region.span.longitudeDelta)
            mapZoomBlocker?.delegate = self
        }
    }
    
    func expandMap() {
        guard !mapExpanded else { return }
        if mapViewContainerExpandable == nil {
            mapViewContainerExpandable = UIView()
        }
        guard let mapViewContainerExpandable = mapViewContainerExpandable else { return }
        addSubview(mapViewContainerExpandable)
        mapViewContainerExpandable.frame = convert(mapViewContainer.frame, from: scrollViewContent)
        layoutMapView(inside: mapViewContainerExpandable)
        
        if let locationZone = self.locationZone {
            mapView.add(locationZone)
        }

        self.delegate?.request(fullScreen: true)
        var expandedFrame = mapViewContainerExpandable.frame
        expandedFrame.origin.y = bigMapMargin
        expandedFrame.size.height = height - (bigMapMargin + bigMapBottomMargin)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mapViewContainerExpandable?.frame = expandedFrame
            self?.mapViewContainerExpandable?.layoutIfNeeded()
            }, completion: { [weak self] completed in
                self?.setupMapExpanded(true)
        })
    }
    
    @objc func compressMap() {
        guard mapExpanded else { return }

        self.delegate?.request(fullScreen: false)
        let compressedFrame = convert(mapViewContainer.frame, from: scrollViewContent)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mapViewContainerExpandable?.frame = compressedFrame
            self?.mapViewContainerExpandable?.layoutIfNeeded()
            }, completion: { [weak self] completed in
                guard let strongSelf = self else { return }
                strongSelf.setupMapExpanded(false)
                if let locationZone = strongSelf.locationZone {
                    strongSelf.mapView.remove(locationZone)
                }
                strongSelf.layoutMapView(inside: strongSelf.mapViewContainer)
                strongSelf.mapViewContainerExpandable?.removeFromSuperview()
                strongSelf.mapZoomBlocker?.stop()
                if let region = strongSelf.vmRegion {
                    strongSelf.mapView.setRegion(region, animated: true)
                }
        })
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
            return renderer
        }
        return MKCircleRenderer()
    }
}

extension ListingCarouselMoreInfoView: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        initialDragYposition = min(max(scrollView.contentOffset.y, 0), bottomScrollLimit)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomOverScroll = max(scrollView.contentOffset.y - bottomScrollLimit, 0)
        visualEffectViewBottom.constant = -bottomOverScroll
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let topOverScroll = abs(min(0, scrollView.contentOffset.y))
        let bottomOverScroll = max(scrollView.contentOffset.y - bottomScrollLimit, 0)
        delegate?.didEndScrolling(topOverScroll, bottomOverScroll: bottomOverScroll)
    }

    var bottomScrollLimit: CGFloat {
        return max(0, scrollView.contentSize.height - scrollView.height + scrollView.contentInset.bottom)
    }
}


// MARK: - Private

fileprivate extension ListingCarouselMoreInfoView {
    func setupUI() {
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-SetupUI-start")
        setupMapView(inside: mapViewContainer)

        mapView.clipsToBounds = true

        titleText.textColor = UIColor.white
        titleText.font = UIFont.productTitleFont
        titleText.linkTextAttributes = [:]
        titleText.textContainerInset = UIEdgeInsets.zero
        titleText.textContainer.lineFragmentPadding = 0
        titleText.delegate = self

        priceLabel.textColor = UIColor.white
        priceLabel.font = UIFont.productPriceFont

        autoTitleLabel.textColor = UIColor.white
        autoTitleLabel.font = UIFont.productTitleDisclaimersFont
        autoTitleLabel.alpha = 0.5

        transTitleLabel.textColor = UIColor.white
        transTitleLabel.font = UIFont.productTitleDisclaimersFont
        transTitleLabel.alpha = 0.5

        addressLabel.textColor = UIColor.white
        addressLabel.font = UIFont.productAddresFont

        distanceLabel.textColor = UIColor.white
        distanceLabel.font = UIFont.productDistanceFont

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDescriptionState))
        descriptionLabel.delegate = self
        descriptionLabel.linkTextAttributes = [:]
        descriptionLabel.textColor = UIColor.grayLight

        descriptionLabel.addGestureRecognizer(tapGesture)
        descriptionLabel.expandText = LGLocalizedString.commonExpand.localizedUppercase
        descriptionLabel.collapseText = LGLocalizedString.commonCollapse.localizedUppercase
        descriptionLabel.gradientColor = .clear
        descriptionLabel.expandTextColor = UIColor.white

        setupSocialShareView()

        dragView.backgroundColor = .clear
        dragButton.clipsToBounds = true
        dragButton.layer.borderColor = UIColor.white.cgColor
        dragButton.layer.borderWidth = 1
        dragButton.backgroundColor = .clear
        
        dragViewTitle.text = LGLocalizedString.productMoreInfoOpenButton
        dragViewTitle.textColor = UIColor.white
        dragViewTitle.font = UIFont.systemSemiBoldFont(size: 13)

        [dragButton, dragViewTitle, dragViewImage].forEach { view in
            view?.layer.shadowColor = UIColor.black.cgColor
            view?.layer.shadowOpacity = 0.5
            view?.layer.shadowRadius = 1
            view?.layer.shadowOffset = CGSize.zero
            view?.layer.masksToBounds = false
        }

        if #available(iOS 11, *) {
            scrollViewToSuperviewTopConstraint.constant = safeAreaInsets.top
        } else {
            scrollViewToSuperviewTopConstraint.constant = ListingCarouselMoreInfoView.navBarDefaultHeight
        }

        scrollView.delegate = self
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-SetupUI-end")
    }
    
    func setupTagCollectionView() {
        tagCollectionViewModel = TagCollectionViewModel(tags: [], cellStyle: .blackBackground, delegate: tagCollectionView)
        tagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.reusableID)
        tagCollectionView.dataSource = tagCollectionViewModel
        tagCollectionView.defaultSetup()
    }

    func setupStatsView() {
        statsContainerViewHeightConstraint.constant = 0.0
        statsContainerViewTopConstraint.constant = 0.0

        guard let statsView = ListingStatsView.make() else { return }
        self.statsView = statsView
        statsContainerView.addSubview(statsView)

        statsView.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: statsView, attribute: .top, relatedBy: .equal, toItem: statsContainerView,
                                     attribute: .top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: statsView, attribute: .trailing, relatedBy: .equal, toItem: statsContainerView,
                                       attribute: .trailing, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: statsView, attribute: .leading, relatedBy: .equal, toItem: statsContainerView,
                                       attribute: .leading, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: statsView, attribute: .bottom, relatedBy: .equal, toItem: statsContainerView,
                                     attribute: .bottom, multiplier: 1, constant: 0)
        statsContainerView.addConstraints([top, right, left, bottom])
    }

    func setupSocialShareView() {
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-setupSocialShareView-start")
        socialShareTitleLabel.textColor = UIColor.white
        socialShareTitleLabel.font = UIFont.productSocialShareTitleFont
        socialShareTitleLabel.text = LGLocalizedString.productShareTitleLabel

        socialShareView.delegate = self
        socialShareView.style = .grid
        socialShareView.gridColumns = 5
        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            socialShareView.buttonsSide = 50
        default: break
        }
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-setupSocialShareView-end")
    }

    fileprivate func hideAdsBanner() {
        bannerContainerView.isHidden = true
        bannerContainerViewHeightConstraint.constant = 0
        if shareViewToMapTopConstraint.isActive {
            shareViewToMapTopConstraint.constant = ListingCarouselMoreInfoView.shareViewToMapMargin
        }
    }

    // MARK: > Configuration (each view model)

    func setupContentRx(viewModel: ListingCarouselViewModel) {

        let statusAndChat = Observable.combineLatest(viewModel.status.asObservable(), viewModel.directChatEnabled.asObservable()) { ($0, $1) }
        statusAndChat.bind { [weak self] (status, chatEnabled) in
            self?.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                                         bottom: status.scrollBottomInset(chatEnabled: chatEnabled), right: 0)
        }.disposed(by: disposeBag)

        viewModel.productInfo.asObservable().unwrap().bind { [weak self] info in
            self?.titleText.attributedText = info.styledTitle
            self?.priceLabel.text = info.price
            self?.autoTitleLabel.text = info.titleAutoGenerated ? LGLocalizedString.productAutoGeneratedTitleLabel : nil
            self?.transTitleLabel.text = info.titleAutoTranslated ? LGLocalizedString.productAutoGeneratedTranslatedTitleLabel : nil
            self?.addressLabel.text = info.address
            self?.distanceLabel.text = info.distance
            self?.descriptionLabel.mainAttributedText = info.styledDescription
            self?.descriptionLabel.setNeedsLayout()
            self?.tagCollectionViewModel?.tags = info.attributeTags ?? []
        }.disposed(by: disposeBag)
    }
    
    func setupStatsRx(viewModel: ListingCarouselViewModel) {
        let productCreation = viewModel.productInfo.asObservable().map { $0?.creationDate }
        let statsAndCreation = Observable.combineLatest(viewModel.listingStats.asObservable().unwrap(), productCreation) { ($0, $1) }
        let statsViewVisible = statsAndCreation.map { (stats, creation) in
            return stats.viewsCount >= Constants.minimumStatsCountToShow || stats.favouritesCount >= Constants.minimumStatsCountToShow || creation != nil
        }
        statsViewVisible.asObservable().distinctUntilChanged().bind { [weak self] visible in
            self?.statsContainerViewHeightConstraint.constant = visible ? self?.statsContainerViewHeight ?? 0 : 0
            self?.statsContainerViewTopConstraint.constant = visible ? self?.statsContainerViewTop ?? 0 : 0
        }.disposed(by: disposeBag)

        statsAndCreation.bind { [weak self] (stats, creation) in
            guard let statsView = self?.statsView else { return }
            statsView.updateStatsWithInfo(stats.viewsCount, favouritesCount: stats.favouritesCount, postedDate: creation)
        }.disposed(by: disposeBag)
    }

    func setupBottomPanelRx(viewModel: ListingCarouselViewModel) {
        viewModel.socialSharer.asObservable().bind { [weak self] socialSharer in
            self?.socialShareView.socialSharer = socialSharer
        }.disposed(by: disposeBag)
        viewModel.socialMessage.asObservable().bind { [weak self] socialMessage in
            self?.socialShareView.socialMessage = socialMessage
            self?.socialShareView.isHidden = socialMessage == nil
        }.disposed(by: disposeBag)
    }

    func setupAdBannerWith(viewModel: ListingCarouselViewModel) {
            dfpBannerView = DFPBannerView(adSize: kGADAdSizeLargeBanner)

            guard let dfpBanner = dfpBannerView else { return }
            dfpBanner.rootViewController = delegate?.rootViewControllerForDFPBanner()
            dfpBanner.delegate = self

            bannerContainerView.addSubview(dfpBanner)
            dfpBanner.translatesAutoresizingMaskIntoConstraints = false
            dfpBanner.layout(with: bannerContainerView).top().bottom().centerX()

            dfpBanner.delegate = self
    }

    func loadDFPRequest() {
        bannerContainerViewHeightConstraint.constant = kGADAdSizeLargeBanner.size.height
        shareViewToMapTopConstraint.isActive = true
        shareViewToBannerTopConstraint.isActive = false

        dfpBannerView?.adUnitID = viewModel?.dfpAdUnitId
        let dfpRequest = DFPRequest()
        dfpRequest.contentURL = viewModel?.dfpContentURL
        dfpBannerView?.load(dfpRequest)
    }
}


// MARK: - GADAdSizeDelegate, GADBannerViewDelegate

extension ListingCarouselMoreInfoView: GADAdSizeDelegate, GADBannerViewDelegate {
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        let sizeFromAdSize = CGSizeFromGADAdSize(size)
        let newFrame = CGRect(x: bannerView.frame.origin.x,
                              y: bannerView.frame.origin.y,
                              width: sizeFromAdSize.width,
                              height: sizeFromAdSize.height)
        bannerView.frame = newFrame
        bannerContainerViewHeightConstraint.constant = sizeFromAdSize.height
        if let sideMargin = viewModel?.sideMargin {
            bannerContainerViewLeftConstraint.constant = sideMargin
            bannerContainerViewRightConstraint.constant = sideMargin
        }
        if sizeFromAdSize.height > 0 {
            let absolutePosition = scrollView.convert(bannerContainerView.frame.origin, to: nil)
            let bannerTop = absolutePosition.y
            let bannerBottom = bannerTop + sizeFromAdSize.height
            viewModel?.didReceiveAd(bannerTopPosition: bannerTop,
                                    bannerBottomPosition: bannerBottom,
                                    screenHeight: UIScreen.main.bounds.height)
        }
    }

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerContainerView.isHidden = false

        bannerContainerViewHeightConstraint.constant = bannerView.height
        shareViewToMapTopConstraint.constant = bannerView.height + ListingCarouselMoreInfoView.shareViewToMapMargin

        if bannerView.frame.size.height > 0 {
            let absolutePosition = scrollView.convert(bannerContainerView.frame.origin, to: nil)
            let bannerTop = absolutePosition.y
            let bannerBottom = bannerTop + bannerView.frame.size.height
            viewModel?.didReceiveAd(bannerTopPosition: bannerTop,
                                    bannerBottomPosition: bannerBottom,
                                    screenHeight: UIScreen.main.bounds.height)
        }
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        logMessage(.info, type: .monetization, message: "MoreInfo banner failed with error: \(error.localizedDescription)")
        bannerContainerViewHeightConstraint.constant = 0
        bannerContainerViewLeftConstraint.constant = 0
        bannerContainerViewRightConstraint.constant = 0

        viewModel?.didFailToReceiveAd(withErrorCode: GADErrorCode(rawValue: error.code) ?? .internalError)
    }

    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        viewModel?.adTapped(typePage: EventParameterTypePage.listingDetailMoreInfo, willLeaveApp: false)
    }

    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        viewModel?.adTapped(typePage: EventParameterTypePage.listingDetailMoreInfo, willLeaveApp: true)
    }
}


// MARK: - LGCollapsibleLabel

extension ListingCarouselMoreInfoView {
    @objc func toggleDescriptionState() {
        UIView.animate(withDuration: 0.25, animations: {
            self.descriptionLabel.toggleState()
            self.layoutIfNeeded()
        }) 
    }
}


// MARK: - UITextViewDelegate

extension ListingCarouselMoreInfoView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if textView === titleText {
            viewModel?.titleURLPressed(URL)
        } else {
            viewModel?.descriptionURLPressed(URL)
        }
        return false
    }
}


// MARK: - SocialShareViewDelegate

extension ListingCarouselMoreInfoView: SocialShareViewDelegate {
    func viewController() -> UIViewController? {
        return delegate?.viewControllerToShowShareOptions()
    }
}


// MARK: - Accessibility ids

extension ListingCarouselMoreInfoView {
    fileprivate func setAccessibilityIds() {
        scrollView.set(accessibilityId: .listingCarouselMoreInfoScrollView)
        titleText.set(accessibilityId: .listingCarouselMoreInfoTitleLabel)
        priceLabel.set(accessibilityId: .listingCarouselMoreInfoPriceLabel)
        transTitleLabel.set(accessibilityId: .listingCarouselMoreInfoTransTitleLabel)
        addressLabel.set(accessibilityId: .listingCarouselMoreInfoAddressLabel)
        distanceLabel.set(accessibilityId: .listingCarouselMoreInfoDistanceLabel)
        mapView.set(accessibilityId: .listingCarouselMoreInfoMapView)
        socialShareTitleLabel.set(accessibilityId: .listingCarouselMoreInfoSocialShareTitleLabel)
        socialShareView.set(accessibilityId: .listingCarouselMoreInfoSocialShareView)
        descriptionLabel.set(accessibilityId: .listingCarouselMoreInfoDescriptionLabel)
        statsView?.set(accessibilityId: .listingCarouselMoreInfoStatsView)
    }
}


// MARK: - Styled listing info

extension ListingVMProductInfo {
    var styledDescription: NSAttributedString? {
        guard let description = description else { return nil }
        let result = NSMutableAttributedString(attributedString: description)
        result.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.grayLight,
                            range: NSMakeRange(0, result.length))
        result.addAttribute(NSAttributedStringKey.font, value: UIFont.productDescriptionFont,
                            range: NSMakeRange(0, result.length))
        return result
    }

    var styledTitle: NSAttributedString? {
        guard let linkedTitle = linkedTitle else { return nil }
        let result = NSMutableAttributedString(attributedString: linkedTitle)
        result.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white,
                            range: NSMakeRange(0, result.length))
        result.addAttribute(NSAttributedStringKey.font, value: UIFont.productTitleFont,
                            range: NSMakeRange(0, result.length))
        return result
    }
}


// MARK: - ListingViewModelStatus

fileprivate extension ListingViewModelStatus {
    func scrollBottomInset(chatEnabled: Bool) -> CGFloat {
        // Needed to avoid drawing content below the chat button
        switch self {
        case .pending, .otherSold, .notAvailable, .otherSoldFree, .pendingAndFeatured:
            // No buttons in the bottom
            return 0
        case .available, .sold, .otherAvailable, .availableFree, .otherAvailableFree, .soldFree:
            if chatEnabled {
                // Has the chatfield at bottom
                return CarouselUI.chatContainerMaxHeight + CarouselUI.itemsMargin
            } else {
                // Has a button in the bottom
                return CarouselUI.buttonHeight + CarouselUI.itemsMargin
            }
        }
    }
}
