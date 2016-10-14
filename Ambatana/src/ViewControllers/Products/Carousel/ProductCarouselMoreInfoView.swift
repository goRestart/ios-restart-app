//
//  ProductCarouselMoreInfoView.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import MapKit
import RxSwift
import LGCollapsibleLabel


protocol ProductCarouselMoreInfoDelegate: class {
    func didEndScrolling(topOverScroll: CGFloat, bottomOverScroll: CGFloat)
    func shareDidFailedWith(error: String)
    func viewControllerToShowShareOptions() -> UIViewController
}


class ProductCarouselMoreInfoView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var autoTitleLabel: UILabel!
    @IBOutlet weak var transTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var socialShareTitleLabel: UILabel!
    @IBOutlet weak var socialShareView: SocialShareView!
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

    
    private let disposeBag = DisposeBag()
    private var currentVmDisposeBag = DisposeBag()
    private var viewModel: ProductViewModel?
    private let overlayMap = MKMapView()
    private var locationZone: MKOverlay?
    private let bigMapMargin: CGFloat = 65.0
    private let bigMapBottomMargin: CGFloat = 210
    private(set) var bigMapVisible = false
    private var mapZoomBlocker: MapZoomBlocker?
    private var statsView: ProductStatsView?

    private let statsContainerViewHeight: CGFloat = 24.0
    private let statsContainerViewTop: CGFloat = 30.0
    private var initialDragYposition: CGFloat = 0
    private var scrollBottomInset: CGFloat {
        guard let status = viewModel?.status.value else { return 0 }
        // Needed to avoid drawing content below the chat button
        switch status {
        case .Pending, .OtherSold, .NotAvailable:
            // No buttons in the bottom
            return 0
        case .PendingAndCommercializable, .Available, .Sold, .OtherAvailable, .AvailableAndCommercializable:
            // Has a button in the bottom
            return 80
        }
    }

    weak var delegate: ProductCarouselMoreInfoDelegate?

    static func moreInfoView(viewModel: ProductViewModel?) -> ProductCarouselMoreInfoView {
        let view = NSBundle.mainBundle().loadNibNamed("ProductCarouselMoreInfoView", owner: self, options: nil)!.first as! ProductCarouselMoreInfoView
        view.viewModel = viewModel
        view.setupUI()
        view.setAccessibilityIds()
        view.setupContent()
        view.addGestures()
        view.configureMapView()
        view.configureOverlayMapView()
        view.setupStatsView()
        return view
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(viewModel: ProductViewModel) {
        self.viewModel = viewModel
        currentVmDisposeBag = DisposeBag()
        setupUI()
        setupContent()
        configureMapView()
        setupStatsRx()
    }

    func dismissed() {
        scrollView.contentOffset = CGPoint.zero
        descriptionLabel.collapsed = true
    }
}


// MARK: - Gesture Intections 

extension ProductCarouselMoreInfoView {
    func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideBigMap))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(hideBigMap))

        scrollView.addGestureRecognizer(tap)
        visualEffectView.addGestureRecognizer(tap2)
    }
}


// MARK: - MapView stuff

extension ProductCarouselMoreInfoView: MKMapViewDelegate {

    func configureMapView() {
        guard let coordinate = viewModel?.productLocation.value else { return }
        let clCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegionMakeWithDistance(clCoordinate, Constants.accurateRegionRadius*2,
                                                        Constants.accurateRegionRadius*2)
        mapView.setRegion(region, animated: true)
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.pitchEnabled = false

        mapZoomBlocker = MapZoomBlocker(mapView: overlayMap, minLatDelta: region.span.latitudeDelta,
                                        minLonDelta: region.span.longitudeDelta)
        mapZoomBlocker?.delegate = self

        locationZone = MKCircle(centerCoordinate:coordinate.coordinates2DfromLocation(),
                                radius: Constants.accurateRegionRadius)
    }

    func configureOverlayMapView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showBigMap))
        mapView.addGestureRecognizer(tap)
        
        overlayMap.frame = convertRect(mapView.frame, fromView: scrollViewContent)
        overlayMap.layer.cornerRadius = LGUIKitConstants.mapCornerRadius
        overlayMap.clipsToBounds = true
        overlayMap.region = mapView.region

        let tapHide = UITapGestureRecognizer(target: self, action: #selector(hideBigMap))
        overlayMap.addGestureRecognizer(tapHide)

        overlayMap.alpha = 0

        addSubview(overlayMap)
    }
    
    func showBigMap() {
        guard !bigMapVisible else { return }
        bigMapVisible = true
        if let locationZone = locationZone {
            overlayMap.addOverlay(locationZone)
        }
        overlayMap.frame = convertRect(mapView.frame, fromView: scrollViewContent)
        overlayMap.region = mapView.region
        overlayMap.alpha = 1

        var newFrame = overlayMap.frame
        newFrame.origin.y = bigMapMargin
        newFrame.size.height = height - bigMapBottomMargin
        UIView.animateWithDuration(0.3) { [weak self] in
            self?.overlayMap.frame = newFrame
        }
    }
    
    func hideBigMap() {
        hideBigMapAnimated(true)
    }

    func hideBigMapAnimated(animated: Bool) {
        guard bigMapVisible else { return }
        bigMapVisible = false
        if let locationZone = locationZone {
            overlayMap.removeOverlay(locationZone)
        }
        let span = mapView.region.span
        let newRegion = MKCoordinateRegion(center: overlayMap.region.center, span: span)
        mapView.region = newRegion
        let newFrame = convertRect(mapView.frame, fromView: scrollViewContent)

        let animations: () -> () = { [weak self] in
            self?.overlayMap.frame = newFrame
        }
        let completion: (Bool) -> () = { [weak self] completed in
            self?.overlayMap.alpha = 0
            self?.configureMapView()
            self?.mapZoomBlocker?.stop()
        }
        if animated {
            UIView.animateWithDuration(0.3, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
            return renderer
        }
        return MKCircleRenderer()
    }
}

extension ProductCarouselMoreInfoView: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        initialDragYposition = min(max(scrollView.contentOffset.y, 0), bottomScrollLimit)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let bottomOverScroll = max(scrollView.contentOffset.y - bottomScrollLimit, 0)
        visualEffectViewBottom.constant = -bottomOverScroll
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let topOverScroll = abs(min(0, scrollView.contentOffset.y))
        let bottomOverScroll = max(scrollView.contentOffset.y - bottomScrollLimit, 0)
        delegate?.didEndScrolling(topOverScroll, bottomOverScroll: bottomOverScroll)
    }

    var bottomScrollLimit: CGFloat {
        return max(0, scrollView.contentSize.height - scrollView.height + scrollView.contentInset.bottom)
    }
}


// MARK: - UI

extension ProductCarouselMoreInfoView {
    private func setupUI() {

        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: scrollBottomInset, right: 0)
        
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont.productTitleFont
        
        priceLabel.textColor = UIColor.whiteColor()
        priceLabel.font = UIFont.productPriceFont
        
        autoTitleLabel.textColor = UIColor.whiteColor()
        autoTitleLabel.font = UIFont.productTitleDisclaimersFont
        autoTitleLabel.alpha = 0.5
        
        transTitleLabel.textColor = UIColor.whiteColor()
        transTitleLabel.font = UIFont.productTitleDisclaimersFont
        transTitleLabel.alpha = 0.5
        
        addressLabel.textColor = UIColor.whiteColor()
        addressLabel.font = UIFont.productAddresFont
        
        distanceLabel.textColor = UIColor.whiteColor()
        distanceLabel.font = UIFont.productDistanceFont
        
        mapView.layer.cornerRadius = LGUIKitConstants.mapCornerRadius
        mapView.clipsToBounds = true
        
        socialShareTitleLabel.textColor = UIColor.whiteColor()
        socialShareTitleLabel.font = UIFont.productSocialShareTitleFont
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDescriptionState))
        descriptionLabel.textColor = UIColor.grayLight
        descriptionLabel.addGestureRecognizer(tapGesture)
        descriptionLabel.expandText = LGLocalizedString.commonExpand.uppercase
        descriptionLabel.collapseText = LGLocalizedString.commonCollapse.uppercase
        descriptionLabel.gradientColor = UIColor.clearColor()
        descriptionLabel.expandTextColor = UIColor.whiteColor()
        
        setupSocialShareView()
        
        dragView.layer.cornerRadius = dragView.height/2
        dragView.layer.borderColor = UIColor.white.CGColor
        dragView.layer.borderWidth = 1
        dragView.backgroundColor = UIColor.clearColor()
        
        dragViewTitle.text = LGLocalizedString.productMoreInfoOpenButton
        dragViewTitle.textColor = UIColor.white
        dragViewTitle.font = UIFont.systemSemiBoldFont(size: 13)
        
        [dragView, dragViewTitle, dragViewImage].forEach { view in
            view.layer.shadowColor = UIColor.black.CGColor
            view.layer.shadowOpacity = 0.5
            view.layer.shadowRadius = 1
            view.layer.shadowOffset = CGSize.zero
            view.layer.masksToBounds = false
        }
        
        scrollView.delegate = self
    }
    
    private func setupContent() {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.productTitle.value
        priceLabel.text = viewModel.productPrice.value
        autoTitleLabel.text = viewModel.productTitleAutogenerated.value ?
            LGLocalizedString.productAutoGeneratedTitleLabel : nil
        transTitleLabel.text = viewModel.productTitleAutoTranslated.value ?
            LGLocalizedString.productAutoGeneratedTranslatedTitleLabel : nil
        
        addressLabel.text = viewModel.productAddress.value
        distanceLabel.text = viewModel.productDistance.value
        
        socialShareTitleLabel.text = LGLocalizedString.productShareTitleLabel
        
        viewModel.productDescription.asObservable().bindTo(descriptionLabel.rx_optionalMainText)
            .addDisposableTo(disposeBag)
        
        socialShareView.socialMessage = viewModel.socialMessage.value
    }
    
    private func setupSocialShareView() {
        socialShareView.delegate = self
        socialShareView.style = .Grid
        socialShareView.gridColumns = 5
        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            socialShareView.buttonsSide = 50
        default: break
        }
    }

    private func setupStatsView() {
        guard let viewModel = viewModel else { return }
        statsContainerViewHeightConstraint.constant = 0.0
        statsContainerViewTopConstraint.constant = 0.0

        guard let statsView = ProductStatsView.productStatsViewWithInfo(viewModel.viewsCount.value,
                                                    favouritesCount: viewModel.favouritesCount.value,
                                                    postedDate: viewModel.productCreationDate.value) else { return }
        self.statsView = statsView
        statsContainerView.addSubview(statsView)

        statsView.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: statsView, attribute: .Top, relatedBy: .Equal, toItem: statsContainerView,
                                     attribute: .Top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: statsView, attribute: .Trailing, relatedBy: .Equal, toItem: statsContainerView,
                                       attribute: .Trailing, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: statsView, attribute: .Leading, relatedBy: .Equal, toItem: statsContainerView,
                                       attribute: .Leading, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: statsView, attribute: .Bottom, relatedBy: .Equal, toItem: statsContainerView,
                                     attribute: .Bottom, multiplier: 1, constant: 0)
        statsContainerView.addConstraints([top, right, left, bottom])

        setupStatsRx()
    }

    private func setupStatsRx() {
        guard let viewModel = viewModel else { return }
        viewModel.statsViewVisible.asObservable().distinctUntilChanged().bindNext { [weak self] visible in
            self?.statsContainerViewHeightConstraint.constant = visible ? self?.statsContainerViewHeight ?? 0 : 0
            self?.statsContainerViewTopConstraint.constant = visible ? self?.statsContainerViewTop ?? 0 : 0
        }.addDisposableTo(currentVmDisposeBag)

        let infos = Observable.combineLatest(viewModel.viewsCount.asObservable(), viewModel.favouritesCount.asObservable(),
                                             viewModel.productCreationDate.asObservable()) { $0 }
        infos.subscribeNext { [weak self] (views, favorites, date) in
                guard let statsView = self?.statsView else { return }
                statsView.updateStatsWithInfo(views, favouritesCount: favorites, postedDate: date)
        }.addDisposableTo(currentVmDisposeBag)
                                 
    }
}


// MARK: - LGCollapsibleLabel

extension ProductCarouselMoreInfoView {
    func toggleDescriptionState() {
        UIView.animateWithDuration(0.25) {
            self.descriptionLabel.toggleState()
            self.layoutIfNeeded()
        }
    }
}



// MARK: - SocialShareViewDelegate

extension ProductCarouselMoreInfoView: SocialShareViewDelegate {
    
    func shareInEmail(){
        viewModel?.shareInEmail(.Bottom)
    }
    
    func shareInEmailFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel?.shareInEmailCompleted()
        case .Cancelled:
            viewModel?.shareInEmailCancelled()
        case .Failed:
            break
        }
    }
    
    func shareInFacebook() {
        viewModel?.shareInFacebook(.Bottom)
    }
    
    func shareInFacebookFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel?.shareInFBCompleted()
        case .Cancelled:
            viewModel?.shareInFBCancelled()
        case .Failed:
            delegate?.shareDidFailedWith(LGLocalizedString.sellSendErrorSharingFacebook)
        }
    }
    
    func shareInFBMessenger() {
        viewModel?.shareInFBMessenger()
    }
    
    func shareInFBMessengerFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel?.shareInFBMessengerCompleted()
        case .Cancelled:
            viewModel?.shareInFBMessengerCancelled()
        case .Failed:
            delegate?.shareDidFailedWith(LGLocalizedString.sellSendErrorSharingFacebook)
        }
    }
    
    func shareInWhatsApp() {
        viewModel?.shareInWhatsApp()
    }
    
    func shareInTwitter() {
        viewModel?.shareInTwitter()
    }
    
    func shareInTwitterFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel?.shareInTwitterCompleted()
        case .Cancelled:
            viewModel?.shareInTwitterCancelled()
        case .Failed:
            break
        }
    }
    
    func shareInTelegram() {
        viewModel?.shareInTelegram()
    }
    
    func viewController() -> UIViewController? {
        return delegate?.viewControllerToShowShareOptions()
    }
    
    func shareInSMS() {
        viewModel?.shareInSMS()
    }
    
    func shareInSMSFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel?.shareInSMSCompleted()
        case .Cancelled:
            viewModel?.shareInSMSCancelled()
        case .Failed:
            delegate?.shareDidFailedWith(LGLocalizedString.productShareSmsError)
        }
    }
    
    func shareInCopyLink() {
        viewModel?.shareInCopyLink()
    }
}


extension ProductCarouselMoreInfoView {
    private func setAccessibilityIds() {
        scrollView.accessibilityId = .ProductCarouselMoreInfoScrollView
        titleLabel.accessibilityId = .ProductCarouselMoreInfoTitleLabel
        transTitleLabel.accessibilityId = .ProductCarouselMoreInfoTransTitleLabel
        addressLabel.accessibilityId = .ProductCarouselMoreInfoAddressLabel
        distanceLabel.accessibilityId = .ProductCarouselMoreInfoDistanceLabel
        mapView.accessibilityId = .ProductCarouselMoreInfoMapView
        socialShareTitleLabel.accessibilityId = .ProductCarouselMoreInfoSocialShareTitleLabel
        socialShareView.accessibilityId = .ProductCarouselMoreInfoSocialShareView
        descriptionLabel.accessibilityId = .ProductCarouselMoreInfoDescriptionLabel
    }
}
