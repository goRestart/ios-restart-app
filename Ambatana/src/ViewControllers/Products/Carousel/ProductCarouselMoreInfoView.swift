//
//  ProductCarouselMoreInfoView.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import MapKit
import LGCoreKit
import RxSwift
import LGCollapsibleLabel

enum MoreInfoState {
    case Hidden
    case Moving
    case Shown
}

protocol ProductCarouselMoreInfoDelegate: class {
    func didEndScrolling(topOverScroll: CGFloat, bottomOverScroll: CGFloat)
    func requestFocus()
    func viewControllerToShowShareOptions() -> UIViewController
}

class ProductCarouselMoreInfoView: UIView {

    private static let relatedItemsHeight: CGFloat = 80
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var autoTitleLabel: UILabel!
    @IBOutlet weak var transTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
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

    @IBOutlet weak var socialShareContainer: UIView!
    @IBOutlet weak var socialShareTitleLabel: UILabel!
    @IBOutlet weak var socialShareView: SocialShareView!

    @IBOutlet weak var relatedItemsContainer: UIView!
    @IBOutlet weak var relatedItemsTitle: UILabel!
    private var relatedProductsView = RelatedProductsView(productsDiameter: ProductCarouselMoreInfoView.relatedItemsHeight,
                                                          frame: CGRect.zero)


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
        case .Pending, .OtherSold, .NotAvailable, .OtherSoldFree:
            // No buttons in the bottom
            return 0
        case .PendingAndCommercializable, .Available, .Sold, .OtherAvailable, .AvailableAndCommercializable, .AvailableFree, .OtherAvailableFree, .SoldFree:
            // Has a button in the bottom
            return 80
        }
    }

    weak var delegate: ProductCarouselMoreInfoDelegate?

    static func moreInfoView() -> ProductCarouselMoreInfoView{
        return moreInfoView(FeatureFlags.sharedInstance)
    }

    static func moreInfoView(featureFlags: FeatureFlaggeable) -> ProductCarouselMoreInfoView {
        let view = NSBundle.mainBundle().loadNibNamed("ProductCarouselMoreInfoView", owner: self, options: nil)!.first as! ProductCarouselMoreInfoView
        view.setupUI(featureFlags)
        view.setupStatsView()
        view.setupOverlayMapView()
        view.setAccessibilityIds()
        view.addGestures()
        return view
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setViewModel(viewModel: ProductViewModel) {
        self.viewModel = viewModel
        currentVmDisposeBag = DisposeBag()
        configureContent()
        configureMapView()
        configureStatsRx()
        configureBottomPanel()
    }

    func viewWillShow() {
        if !relatedItemsContainer.hidden {
            relatedProductsView.productId.value = viewModel?.product.value.objectId
        }
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
        visualEffectView.addGestureRecognizer(tap)
    }
}


// MARK: - MapView stuff

extension ProductCarouselMoreInfoView: MKMapViewDelegate {

    // Initial setup
    func setupOverlayMapView() {
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

    // Configuration for each VM
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
    
    func showBigMap() {
        guard !bigMapVisible else { return }
        bigMapVisible = true
        delegate?.requestFocus()
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


// MARK: - Private

private extension ProductCarouselMoreInfoView {


    // MARK: > Setup (initial)

    func setupUI(featureFlags: FeatureFlaggeable) {
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDescriptionState))
        descriptionLabel.textColor = UIColor.grayLight
        descriptionLabel.addGestureRecognizer(tapGesture)
        descriptionLabel.expandText = LGLocalizedString.commonExpand.uppercase
        descriptionLabel.collapseText = LGLocalizedString.commonCollapse.uppercase
        descriptionLabel.gradientColor = UIColor.clearColor()
        descriptionLabel.expandTextColor = UIColor.whiteColor()

        setupSocialShareView()
        setupRelatedItems()
        socialShareContainer.hidden = featureFlags.relatedProductsOnMoreInfo
        relatedItemsContainer.hidden = !featureFlags.relatedProductsOnMoreInfo

        dragView.rounded = true
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

    private func setupStatsView() {
        statsContainerViewHeightConstraint.constant = 0.0
        statsContainerViewTopConstraint.constant = 0.0

        guard let statsView = ProductStatsView.productStatsView() else { return }
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
    }

    private func setupSocialShareView() {
        socialShareTitleLabel.textColor = UIColor.whiteColor()
        socialShareTitleLabel.font = UIFont.productSocialShareTitleFont
        socialShareTitleLabel.text = LGLocalizedString.productShareTitleLabel

        socialShareView.delegate = self
        socialShareView.style = .Grid
        socialShareView.gridColumns = 5
        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            socialShareView.buttonsSide = 50
        default: break
        }
    }

    private func setupRelatedItems() {
        relatedItemsTitle.textColor = UIColor.whiteColor()
        relatedItemsTitle.font = UIFont.productRelatedItemsTitleFont
        relatedItemsTitle.text = LGLocalizedString.productMoreInfoRelatedTitle

        relatedProductsView.translatesAutoresizingMaskIntoConstraints = false
        relatedItemsContainer.addSubview(relatedProductsView)

        let views = [ "title" : relatedItemsTitle, "items" : relatedProductsView ]
        let metrics = [ "interMargin" : CGFloat(10), "margin" : CGFloat(15), "height" : ProductCarouselMoreInfoView.relatedItemsHeight]
        relatedItemsContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[title]-interMargin-[items(height)]-margin-|",
            options: [], metrics: metrics, views: views))
        relatedItemsContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[items]-0-|",
            options: [], metrics: metrics, views: views))

        relatedProductsView.hasProducts.asObservable().distinctUntilChanged()
            .map { $0 ? CGFloat(1) : CGFloat(0) }
            .bindNext { alpha in
                UIView.animateWithDuration(0.2) { [weak self] in
                    self?.relatedItemsContainer.alpha = alpha
                }
            }.addDisposableTo(disposeBag)

        relatedProductsView.delegate = self
    }


    // MARK: > Configuration (each view model)

    private func configureContent() {
        guard let viewModel = viewModel else { return }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: scrollBottomInset, right: 0)

        titleLabel.text = viewModel.productTitle.value
        priceLabel.text = viewModel.productPrice.value
        autoTitleLabel.text = viewModel.productTitleAutogenerated.value ?
            LGLocalizedString.productAutoGeneratedTitleLabel : nil
        transTitleLabel.text = viewModel.productTitleAutoTranslated.value ?
            LGLocalizedString.productAutoGeneratedTranslatedTitleLabel : nil

        addressLabel.text = viewModel.productAddress.value
        distanceLabel.text = viewModel.productDistance.value

        viewModel.productDescription.asObservable().bindTo(descriptionLabel.rx_optionalMainText)
            .addDisposableTo(disposeBag)
    }

    private func configureStatsRx() {
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

    private func configureBottomPanel() {
        guard let viewModel = viewModel else { return }

        if !socialShareContainer.hidden {
            socialShareView.socialMessage = viewModel.socialMessage.value
            socialShareView.socialSharer = viewModel.socialSharer
        }
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
    func viewController() -> UIViewController? {
        return delegate?.viewControllerToShowShareOptions()
    }
}


// MARK: - RelatedProductsViewDelegate

extension ProductCarouselMoreInfoView: RelatedProductsViewDelegate {
    func relatedProductsView(view: RelatedProductsView, showProduct product: Product, atIndex index: Int,
                             productListModels: [ProductCellModel], requester: ProductListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?) {
        var finalFrame: CGRect? = nil
        if let originFrame = originFrame {
            finalFrame = relatedItemsContainer.convertRect(originFrame, toView: self)
        }
        viewModel?.relatedProductsView(view, showProduct: product, atIndex: index, productListModels: productListModels,
                                       requester: requester, thumbnailImage: thumbnailImage, originFrame: finalFrame)
    }
}


// MARK: - Accessibility ids

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
        relatedItemsTitle.accessibilityId = .ProductCarouselMoreInfoRelatedItemsTitleLabel
        relatedProductsView.accessibilityId = .ProductCarouselMoreInfoRelatedItemsView
    }
}
