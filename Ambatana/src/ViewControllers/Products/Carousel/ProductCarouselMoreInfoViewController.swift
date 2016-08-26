//
//  ProductCarouselMoreInfoViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import MapKit
import RxSwift
import LGCollapsibleLabel

class ProductCarouselMoreInfoViewController: BaseViewController {
    
    @IBOutlet weak var closeButton: UIButton!
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
    @IBOutlet weak var descriptionLabel: LGCollapsibleLabel!
    @IBOutlet weak var statsContainerView: UIView!
    @IBOutlet weak var statsContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statsContainerViewTopConstraint: NSLayoutConstraint!

    private let disposeBag = DisposeBag()
    private let viewModel: ProductViewModel
    private let overlayMap = MKMapView()
    private var locationZone: MKOverlay?
    private let bigMapMargin: CGFloat = 65.0
    private var bigMapVisible = false
    private let dismissBlock: ((viewToHide: UIView) -> ())?
    private var mapZoomBlocker: MapZoomBlocker?


    private let statsContainerViewHeight: CGFloat = 24.0
    private let statsContainerViewTop: CGFloat = 30.0


    init(viewModel: ProductViewModel, dismissBlock: ((viewToHide: UIView) -> ())?) {
        self.viewModel = viewModel
        self.dismissBlock = dismissBlock
        super.init(viewModel: viewModel, nibName: "ProductCarouselMoreInfoViewController",
                   statusBarStyle: .LightContent)
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupContent()
        addGestures()
        configureMapView()
        setAccessibilityIds()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        configureOverlayMapView()
    }
}


// MARK: - Gesture Intections 

extension ProductCarouselMoreInfoViewController {
    func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeView))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(closeView))

        scrollView.addGestureRecognizer(tap)
        visualEffectView.addGestureRecognizer(tap2)
    }
}


// MARK: - MapView stuff

extension ProductCarouselMoreInfoViewController: MKMapViewDelegate {

    func configureMapView() {
        guard let coordinate = viewModel.productLocation.value else { return }
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
    }

    func configureOverlayMapView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showBigMap))
        mapView.addGestureRecognizer(tap)
        
        overlayMap.frame = view.convertRect(mapView.frame, fromView: scrollViewContent)
        overlayMap.layer.cornerRadius = LGUIKitConstants.mapCornerRadius
        overlayMap.clipsToBounds = true
        overlayMap.region = mapView.region

        let tapHide = UITapGestureRecognizer(target: self, action: #selector(hideBigMap))
        overlayMap.addGestureRecognizer(tapHide)

        overlayMap.alpha = 0

        if let coordinate = viewModel.productLocation.value {
            locationZone = MKCircle(centerCoordinate:coordinate.coordinates2DfromLocation(),
                                  radius: Constants.accurateRegionRadius)
        }

        view.addSubview(overlayMap)
    }
    
    func showBigMap() {
        guard !bigMapVisible else { return }
        bigMapVisible = true
        if let locationZone = locationZone {
            overlayMap.addOverlay(locationZone)
        }
        overlayMap.frame = view.convertRect(mapView.frame, fromView: scrollViewContent)
        overlayMap.region = mapView.region
        overlayMap.alpha = 1

        var newFrame = overlayMap.frame
        newFrame.origin.y = bigMapMargin
        newFrame.size.height = view.height - bigMapMargin*2
        UIView.animateWithDuration(0.3) { [weak self] in
            self?.overlayMap.frame = newFrame
        }
    }
    
    func hideBigMap() {
        guard bigMapVisible else { return }
        bigMapVisible = false
        if let locationZone = locationZone {
            overlayMap.removeOverlay(locationZone)
        }
        let span = mapView.region.span
        let newRegion = MKCoordinateRegion(center: overlayMap.region.center, span: span)
        mapView.region = newRegion
        let newFrame = view.convertRect(mapView.frame, fromView: scrollViewContent)
        UIView.animateWithDuration(0.3, animations: { [weak self] in
            self?.overlayMap.frame = newFrame
            }) { [weak self] completed in
                self?.overlayMap.alpha = 0
                self?.configureMapView()
                self?.mapZoomBlocker?.stop()
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

extension ProductCarouselMoreInfoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -100 {
            closeView()
        }
    }
}


// MARK: - UI

extension ProductCarouselMoreInfoViewController {
    private func setupUI() {
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
        setupStatsView()
        
        scrollView.delegate = self
    }
    
    private func setupContent() {
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
        statsContainerViewHeightConstraint.constant = 0.0
        statsContainerViewTopConstraint.constant = 0.0

        guard let statsView = ProductStatsView.productStatsViewWithInfo(viewModel.viewsCount.value,
                                                    favouritesCount: viewModel.favouritesCount.value,
                                                    postedDate: viewModel.productCreationDate.value) else { return }
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


        viewModel.statsViewVisible.asObservable().subscribeNext { [weak self] statsViewVisible in
            if statsViewVisible { self?.updateStatsView(statsView) }
        }.addDisposableTo(disposeBag)
    }

    private func updateStatsView(statsView: ProductStatsView) {
        statsContainerViewHeightConstraint.constant = viewModel.statsViewVisible.value ? statsContainerViewHeight : 0.0
        statsContainerViewTopConstraint.constant = viewModel.statsViewVisible.value ? statsContainerViewTop : 0.0
        statsView.updateStatsWithInfo(viewModel.viewsCount.value, favouritesCount: viewModel.favouritesCount.value,
                                      postedDate: viewModel.productCreationDate.value)
    }
}


// MARK: - LGCollapsibleLabel

extension ProductCarouselMoreInfoViewController {
    func toggleDescriptionState() {
        UIView.animateWithDuration(0.25) {
            self.descriptionLabel.toggleState()
            self.view.layoutIfNeeded()
        }
    }
}


// MARK: - IB Actions

extension ProductCarouselMoreInfoViewController {
    
    @IBAction func closeView() {
        if bigMapVisible {
            hideBigMap()
        } else {
            closeButton.alpha = 0
            dismissBlock?(viewToHide: view)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}


// MARK: - SocialShareViewDelegate

extension ProductCarouselMoreInfoViewController: SocialShareViewDelegate {
    
    func shareInEmail(){
        viewModel.shareInEmail(.Bottom)
    }
    
    func shareInEmailFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.shareInEmailCompleted()
        case .Cancelled:
            viewModel.shareInEmailCancelled()
        case .Failed:
            break
        }
    }
    
    func shareInFacebook() {
        viewModel.shareInFacebook(.Bottom)
    }
    
    func shareInFacebookFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.shareInFBCompleted()
        case .Cancelled:
            viewModel.shareInFBCancelled()
        case .Failed:
            showAutoFadingOutMessageAlert(LGLocalizedString.sellSendErrorSharingFacebook)
        }
    }
    
    func shareInFBMessenger() {
        viewModel.shareInFBMessenger()
    }
    
    func shareInFBMessengerFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.shareInFBMessengerCompleted()
        case .Cancelled:
            viewModel.shareInFBMessengerCancelled()
        case .Failed:
            showAutoFadingOutMessageAlert(LGLocalizedString.sellSendErrorSharingFacebook)
        }
    }
    
    func shareInWhatsApp() {
        viewModel.shareInWhatsApp()
    }
    
    func shareInTwitter() {
        viewModel.shareInTwitter()
    }
    
    func shareInTwitterFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.shareInTwitterCompleted()
        case .Cancelled:
            viewModel.shareInTwitterCancelled()
        case .Failed:
            break
        }
    }
    
    func shareInTelegram() {
        viewModel.shareInTelegram()
    }
    
    func viewController() -> UIViewController? {
        return self
    }
    
    func shareInSMS() {
        viewModel.shareInSMS()
    }
    
    func shareInSMSFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.shareInSMSCompleted()
        case .Cancelled:
            viewModel.shareInSMSCancelled()
        case .Failed:
            showAutoFadingOutMessageAlert(LGLocalizedString.productShareSmsError)
        }
    }
    
    func shareInCopyLink() {
        viewModel.shareInCopyLink()
    }
}


extension ProductCarouselMoreInfoViewController {
    private func setAccessibilityIds() {
        scrollView.accessibilityId = .ProductCarouselMoreInfoScrollView
        closeButton.accessibilityId = .ProductCarouselMoreInfoCloseButton
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
