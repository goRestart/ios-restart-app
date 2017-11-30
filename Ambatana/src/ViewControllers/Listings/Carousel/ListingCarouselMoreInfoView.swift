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

enum MoreInfoState {
    case hidden
    case moving
    case shown
}

protocol ProductCarouselMoreInfoDelegate: class {
    func didEndScrolling(_ topOverScroll: CGFloat, bottomOverScroll: CGFloat)
    func request(fullScreen: Bool)
    func viewControllerToShowShareOptions() -> UIViewController
}

extension MKMapView {
    // Create a unique isntance of MKMapView due to: http://stackoverflow.com/questions/36417350/mkmapview-using-a-lot-of-memory-each-time-i-load-its-view
    @nonobjc static let sharedInstance = MKMapView()
}

class ListingCarouselMoreInfoView: UIView {

    fileprivate static let relatedItemsHeight: CGFloat = 80

    @IBOutlet weak var titleText: UITextView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var autoTitleLabel: UILabel!
    @IBOutlet weak var transTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContent: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var visualEffectViewBottom: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: LGCollapsibleLabel!
    @IBOutlet weak var statsContainerView: UIView!
    @IBOutlet weak var statsContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statsContainerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dragView: UIView!
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

    var bannerView: GADSearchBannerView?

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

    static func moreInfoView() -> ListingCarouselMoreInfoView {
        guard let view = Bundle.main.loadNibNamed("ListingCarouselMoreInfoView", owner: self, options: nil)?.first
            as? ListingCarouselMoreInfoView else { return ListingCarouselMoreInfoView() }
        view.setupUI()
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
            setupBannerWith(viewModel: viewModel)
        }
    }

    func viewWillShow() {
        setupMapViewIfNeeded()
        if let adActive = viewModel?.adActive, adActive {
            if let adBannerTrackingStatus = viewModel?.adBannerTrackingStatus {
                viewModel?.adAlreadyRequestedWithStatus(adBannerTrackingStatus: adBannerTrackingStatus)
            } else {
                loadAFShoppingRequest()
            }
        }
    }

    func dismissed() {
        scrollView.contentOffset = CGPoint.zero
        descriptionLabel.collapsed = true
    }
    
    deinit {
        // MapView is a shared instance and all references must be removed
        cleanMapView()
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
        layoutMapView(inside: container)
        addMapGestures()
    }

    fileprivate func setupMapRx(viewModel: ListingCarouselViewModel) {
        let productLocation = viewModel.productInfo.asObservable().map { $0?.location }.unwrap()
        productLocation.bindNext { [weak self] coordinate in
            self?.addRegion(with: coordinate, zoomBlocker: true)
            self?.setupMapExpanded(false)
            self?.locationZone = MKCircle(center:coordinate.coordinates2DfromLocation(),
                                    radius: Constants.accurateRegionRadius)
        }.addDisposableTo(disposeBag)
    }

    private func layoutMapView(inside container: UIView) {
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
    
    dynamic func didTapMap() {
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
    
    func compressMap() {
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
        
        setupMapView(inside: mapViewContainer)
        mapView.layer.cornerRadius = LGUIKitConstants.mapCornerRadius
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

        dragView.rounded = true
        dragView.layer.borderColor = UIColor.white.cgColor
        dragView.layer.borderWidth = 1
        dragView.backgroundColor = .clear
        
        dragViewTitle.text = LGLocalizedString.productMoreInfoOpenButton
        dragViewTitle.textColor = UIColor.white
        dragViewTitle.font = UIFont.systemSemiBoldFont(size: 13)
        
        [dragView, dragViewTitle, dragViewImage].forEach { view in
            view?.layer.shadowColor = UIColor.black.cgColor
            view?.layer.shadowOpacity = 0.5
            view?.layer.shadowRadius = 1
            view?.layer.shadowOffset = CGSize.zero
            view?.layer.masksToBounds = false
        }
        
        scrollView.delegate = self
    }

    func setupStatsView() {
        statsContainerViewHeightConstraint.constant = 0.0
        statsContainerViewTopConstraint.constant = 0.0

        guard let statsView = ListingStatsView.ListingStatsView() else { return }
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
    }


    // MARK: > Configuration (each view model)

    func setupContentRx(viewModel: ListingCarouselViewModel) {

        let statusAndChat = Observable.combineLatest(viewModel.status.asObservable(), viewModel.directChatEnabled.asObservable()) { $0 }
        statusAndChat.bindNext { [weak self] (status, chatEnabled) in
            self?.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                                         bottom: status.scrollBottomInset(chatEnabled: chatEnabled), right: 0)
        }.addDisposableTo(disposeBag)

        viewModel.productInfo.asObservable().unwrap().bindNext { [weak self] info in
            self?.titleText.attributedText = info.styledTitle
            self?.priceLabel.text = info.price
            self?.autoTitleLabel.text = info.titleAutoGenerated ? LGLocalizedString.productAutoGeneratedTitleLabel : nil
            self?.transTitleLabel.text = info.titleAutoTranslated ? LGLocalizedString.productAutoGeneratedTranslatedTitleLabel : nil
            self?.addressLabel.text = info.address
            self?.distanceLabel.text = info.distance
            self?.descriptionLabel.mainAttributedText = info.styledDescription
            self?.descriptionLabel.setNeedsLayout()
        }.addDisposableTo(disposeBag)
    }

    func setupStatsRx(viewModel: ListingCarouselViewModel) {
        let productCreation = viewModel.productInfo.asObservable().map { $0?.creationDate }
        let statsAndCreation = Observable.combineLatest(viewModel.listingStats.asObservable().unwrap(), productCreation) { $0 }
        let statsViewVisible = statsAndCreation.map { (stats, creation) in
            return stats.viewsCount >= Constants.minimumStatsCountToShow || stats.favouritesCount >= Constants.minimumStatsCountToShow || creation != nil
        }
        statsViewVisible.asObservable().distinctUntilChanged().bindNext { [weak self] visible in
            self?.statsContainerViewHeightConstraint.constant = visible ? self?.statsContainerViewHeight ?? 0 : 0
            self?.statsContainerViewTopConstraint.constant = visible ? self?.statsContainerViewTop ?? 0 : 0
        }.addDisposableTo(disposeBag)

        statsAndCreation.bindNext { [weak self] (stats, creation) in
            guard let statsView = self?.statsView else { return }
            statsView.updateStatsWithInfo(stats.viewsCount, favouritesCount: stats.favouritesCount, postedDate: creation)
        }.addDisposableTo(disposeBag)
    }

    func setupBottomPanelRx(viewModel: ListingCarouselViewModel) {
        viewModel.socialSharer.asObservable().bindNext { [weak self] socialSharer in
            self?.socialShareView.socialSharer = socialSharer
        }.addDisposableTo(disposeBag)
        viewModel.socialMessage.asObservable().bindNext { [weak self] socialMessage in
            self?.socialShareView.socialMessage = socialMessage
            self?.socialShareView.isHidden = socialMessage == nil
        }.addDisposableTo(disposeBag)
    }

    func setupBannerWith(viewModel: ListingCarouselViewModel) {

        bannerView = GADSearchBannerView.init(adSize: kGADAdSizeFluid)
        guard let bannerView = bannerView else { return }
        bannerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0)

        bannerView.autoresizingMask = .flexibleWidth
        bannerView.adSizeDelegate = self
        bannerView.delegate = self

        bannerContainerView.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.layout(with: bannerContainerView).fill()
    }

    func loadAFShoppingRequest() {
        bannerView?.adUnitID = viewModel?.shoppingAdUnitId
        bannerView?.load(viewModel?.makeAFShoppingRequestWithWidth(width: frame.width))
    }
}


// MARK: - GADAdSizeDelegate, GADBannerViewDelegate

extension ListingCarouselMoreInfoView: GADAdSizeDelegate, GADBannerViewDelegate {
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        let newFrame = CGRect(x: bannerView.frame.origin.x, y: bannerView.frame.origin.y, width: size.size.width, height: size.size.height)
        bannerView.frame = newFrame
        bannerContainerViewHeightConstraint.constant = size.size.height
        if let sideMargin = viewModel?.sideMargin {
            bannerContainerViewLeftConstraint.constant = sideMargin
            bannerContainerViewRightConstraint.constant = sideMargin
        }
        if size.size.height > 0 {
            let absolutePosition = scrollView.convert(bannerContainerView.frame.origin, to: nil)
            let bannerTop = absolutePosition.y
            let bannerBottom = bannerTop + size.size.height
            viewModel?.didReceiveAd(bannerTopPosition: bannerTop,
                                    bannerBottomPosition: bannerBottom,
                                    screenHeight: UIScreen.main.bounds.height)
        }
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        logMessage(.info, type: .monetization, message: "Banner failed with error: \(error.localizedDescription)")
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
    func toggleDescriptionState() {
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
        scrollView.accessibilityId = .listingCarouselMoreInfoScrollView
        titleText.accessibilityId = .listingCarouselMoreInfoTitleLabel
        transTitleLabel.accessibilityId = .listingCarouselMoreInfoTransTitleLabel
        addressLabel.accessibilityId = .listingCarouselMoreInfoAddressLabel
        distanceLabel.accessibilityId = .listingCarouselMoreInfoDistanceLabel
        mapView.accessibilityId = .listingCarouselMoreInfoMapView
        socialShareTitleLabel.accessibilityId = .listingCarouselMoreInfoSocialShareTitleLabel
        socialShareView.accessibilityId = .listingCarouselMoreInfoSocialShareView
        descriptionLabel.accessibilityId = .listingCarouselMoreInfoDescriptionLabel
    }
}


// MARK: - Styled listing info

extension ListingVMProductInfo {
    var styledDescription: NSAttributedString? {
        guard let description = description else { return nil }
        let result = NSMutableAttributedString(attributedString: description)
        result.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayLight,
                                range: NSMakeRange(0, result.length))
        result.addAttribute(NSFontAttributeName, value: UIFont.productDescriptionFont,
                            range: NSMakeRange(0, result.length))
        return result
    }

    var styledTitle: NSAttributedString? {
        guard let linkedTitle = linkedTitle else { return nil }
        let result = NSMutableAttributedString(attributedString: linkedTitle)
        result.addAttribute(NSForegroundColorAttributeName, value: UIColor.white,
                            range: NSMakeRange(0, result.length))
        result.addAttribute(NSFontAttributeName, value: UIFont.productTitleFont,
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
