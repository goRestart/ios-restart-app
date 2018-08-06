import MapKit
import LGCoreKit
import RxSwift
import LGCollapsibleLabel
import GoogleMobileAds
import LGComponents

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

final class ListingCarouselMoreInfoView: UIView {

    private static let mapPinAnnotationReuseId = "mapPin"

    //  MARK: - Subviews
    
    private let visualEffectView: UIVisualEffectView = {
       let visualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffect.backgroundColor = .clear
        return visualEffect
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.set(accessibilityId: .listingCarouselMoreInfoScrollView)
        return scrollView
    }()

    private let scrollViewContent = UIView()

    let dragView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .productTitleFont
        label.textAlignment = .left
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.set(accessibilityId: .listingCarouselMoreInfoTitleLabel)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = .productPriceFont
        label.minimumScaleFactor = 0.8
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.set(accessibilityId: .listingCarouselMoreInfoPriceLabel)
        return label
    }()
    
    private let autoTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .productTitleDisclaimersFont
        label.alpha = 0.5
        label.textAlignment = .left
        return label
    }()
    
    private let transTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .productTitleDisclaimersFont
        label.alpha = 0.5
        label.set(accessibilityId: .listingCarouselMoreInfoTransTitleLabel)
        return label
    }()
    
    private let descriptionLabel: LGCollapsibleLabel = {
        let label = LGCollapsibleLabel()
        label.linkTextAttributes = [:]
        label.textColor = .grayLight
        label.expandText = R.Strings.commonExpand.localizedUppercase
        label.collapseText = R.Strings.commonCollapse.localizedUppercase
        label.gradientColor = .clear
        label.expandTextColor = .white
        label.set(accessibilityId: .listingCarouselMoreInfoDescriptionLabel)
        return label
    }()
    
    private let attributeGridView = ListingCarouselMoreInfoViewAttributeGridView(frame: .zero)
    
    private var tagCollectionViewModel = TagCollectionViewModel(cellStyle: .blackBackground)
    private lazy var tagCollectionView: TagCollectionView = {
        let tagCollectionView = TagCollectionView(viewModel: tagCollectionViewModel, flowLayout: .leftAligned)
        tagCollectionView.register(type: TagCollectionViewCell.self)
        tagCollectionView.defaultSetup()
        return tagCollectionView
    }()
    
    private let statsContainerView = UIView()
    private let statsView = ListingStatsView.make()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = .productAddresFont
        label.set(accessibilityId: .listingCarouselMoreInfoAddressLabel)
        return label
    }()
    
    private let addressIcon: UIImageView = {
        let imageView = UIImageView(image: R.Asset.IconsButtons.itemLocationWhite.image)
        imageView.clipsToBounds = true
        return imageView
    }()

    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .productDistanceFont
        label.set(accessibilityId: .listingCarouselMoreInfoDistanceLabel)
        return label
    }()
    
    private let mapViewContainer = UIView()
    private lazy var mapViewContainerExpandable = UIView()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView.sharedInstance
        mapView.set(accessibilityId: .listingCarouselMoreInfoMapView)
        mapView.cornerRadius = LGUIKitConstants.bigCornerRadius
        mapView.cornerRadius = LGUIKitConstants.bigCornerRadius
        return mapView
    }()
    
    private let bannerContainerView = UIView()
    private let socialShareContainer = UIView()
    
    private let socialShareTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .productSocialShareTitleFont
        label.text = R.Strings.productShareTitleLabel
        label.set(accessibilityId: .listingCarouselMoreInfoSocialShareTitleLabel)
        return label
    }()
    
    private let socialShareView: SocialShareView = {
        let view = SocialShareView()
        view.style = .grid
        view.gridColumns = Layout.SocialShare.columns
        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            view.buttonsSide = Layout.SocialShare.buttonSideSort
        default: break
        }
        view.set(accessibilityId: .listingCarouselMoreInfoSocialShareView)
        return view
    }()
    
    private let dragButton: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .clear
        view.cornerRadius = Layout.DragView.height/2
        view.applyShadow(withOpacity: 0.5, radius: 1)
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        view.layer.masksToBounds = false
        return view
    }()
    
    private let dragViewTitle: UILabel = {
        let label = UILabel()
        label.text = R.Strings.productMoreInfoOpenButton
        label.textColor = .white
        label.font = .systemSemiBoldFont(size: 13)
        label.applyShadow(withOpacity: 0.5, radius: 1)
        label.layer.masksToBounds = false
        return label
    }()
    
    private let dragViewImage: UIImageView = {
        let imageView = UIImageView(image: R.Asset.IconsButtons.icArrowDown.image)
        imageView.contentMode = .scaleAspectFit
        imageView.applyShadow(withOpacity: 0.5, radius: 1)
        return imageView
    }()
    
    //  MARK: - Constraints
    
    private var scrollViewBottomConstraint: NSLayoutConstraint?
    private var visualEffectViewBottom: NSLayoutConstraint?
    private var statsContainerViewHeightConstraint: NSLayoutConstraint?
    private var attributeGridViewHeightConstraint: NSLayoutConstraint?
    private var bannerContainerViewHeightConstraint: NSLayoutConstraint?
    private var bannerContainerViewLeftConstraint: NSLayoutConstraint?
    private var bannerContainerViewRightConstraint: NSLayoutConstraint?
    private var shareViewToMapTopConstraint: NSLayoutConstraint?
    private var shareViewToBannerTopConstraint: NSLayoutConstraint?
    

    
    
    private let disposeBag = DisposeBag()
    
    private var locationZone: MKOverlay?
    private var vmRegion: MKCoordinateRegion? = nil
    private var mapViewTapGesture: UITapGestureRecognizer? = nil
    private var mapPinCustomAnnotation: MKPointAnnotation?
    private(set) var mapExpanded: Bool = false
    private var mapZoomBlocker: MapZoomBlocker?

    var dfpBannerView: DFPBannerView?
    weak var viewModel: ListingCarouselViewModel?
    weak var delegate: ProductCarouselMoreInfoDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setAccessibilityIds()
        addGestures()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-SetupUI-start")
        addSubviews()
        setupMapView(inside: mapViewContainer)
        setupSocialShareView()
        setupDescriptionLabel()
        scrollView.delegate = self
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-SetupUI-end")
    }
    
    private func addSubviews() {
        addSubviewsForAutoLayout([visualEffectView, scrollView, dragView])
        scrollView.addSubviewForAutoLayout(scrollViewContent)
        scrollViewContent.addSubviewsForAutoLayout([titleLabel, priceLabel, autoTitleLabel, transTitleLabel,
                                                    descriptionLabel, attributeGridView, tagCollectionView, statsContainerView,
                                                    addressLabel,addressIcon, distanceLabel, mapViewContainer, bannerContainerView, socialShareContainer])
        if let statsView = statsView {
            statsContainerView.addSubviewForAutoLayout(statsView)
        }
        socialShareContainer.addSubviewsForAutoLayout([socialShareTitleLabel, socialShareView])
        
        dragView.addSubviewsForAutoLayout([dragButton])
        dragButton.addSubviewsForAutoLayout([dragViewTitle, dragViewImage])
    }
    
    private func setupDescriptionLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDescriptionState))
        descriptionLabel.delegate = self
        descriptionLabel.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        
        //  VisualEffect
        visualEffectView.layout(with: self)
            .fillHorizontal().top(by: Layout.VisualEffect.top)
        visualEffectViewBottom = visualEffectView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        visualEffectViewBottom?.isActive = true
        
        //  ScrollView
        
        scrollView.layout(with: self)
            .fillHorizontal()
        scrollViewBottomConstraint = bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        
        if #available(iOS 11, *) {
            scrollView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor,
                                            constant: safeAreaInsets.top).isActive = true
        } else {
            scrollView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor,
                                            constant: Layout.ScrollView.top).isActive = true
        }
        scrollViewBottomConstraint?.isActive = true
        
        scrollViewContent.layout(with: scrollView)
            .leading().proportionalWidth().top().bottom()

        titleLabel.layout(with: scrollViewContent)
            .leading(by: Metrics.margin).top(by: Metrics.margin)

        priceLabel.layout(with: scrollViewContent)
            .trailing(by: -Metrics.margin)
        priceLabel.layout(with: titleLabel).toLeft(by: Metrics.shortMargin).firstBaseline()

        autoTitleLabel.layout(with: titleLabel)
            .leading().below()
        autoTitleLabel.layout(with: scrollViewContent).trailing()
        
        transTitleLabel.layout(with: autoTitleLabel)
            .leading().below()
        transTitleLabel.layout(with: scrollViewContent).trailing()

        descriptionLabel.layout(with: scrollViewContent)
            .fillHorizontal(by: Metrics.shortMargin)
        descriptionLabel.layout(with: transTitleLabel).below(by: Metrics.shortMargin)
        
        attributeGridView.layout(with: scrollViewContent)
            .fillHorizontal()
        attributeGridViewHeightConstraint = attributeGridView.heightAnchor.constraint(equalToConstant: Layout.AttributeGrid.height)
        attributeGridViewHeightConstraint?.isActive = true
        attributeGridView.layout(with: descriptionLabel)
            .below(by: Metrics.veryBigMargin)

        tagCollectionView.layout(with: scrollViewContent)
            .fillHorizontal(by: Metrics.margin)
        tagCollectionView.layout(with: attributeGridView)
            .below(by: Metrics.veryBigMargin)
        
        statsContainerView.layout(with: scrollViewContent).fillHorizontal(by: Metrics.margin)
        statsContainerViewHeightConstraint = statsContainerView.heightAnchor.constraint(equalToConstant: Layout.Stats.height)
        statsContainerViewHeightConstraint?.isActive = true
        statsContainerView.layout(with: descriptionLabel)
            .below(by: Metrics.veryBigMargin, relatedBy: .greaterThanOrEqual, priority: .defaultLow)
        statsContainerView.layout(with: tagCollectionView)
            .below(by: Metrics.veryBigMargin, relatedBy: .greaterThanOrEqual, priority: .defaultLow)
        statsView?.layout(with: statsContainerView).fill()
        
        addressLabel.layout(with: addressIcon).toLeft(by: Metrics.veryShortMargin)
        addressLabel.layout(with: statsContainerView).below(by: Metrics.veryBigMargin)
        
        addressIcon.layout(with: scrollViewContent).leading(by: Metrics.margin)
        addressIcon.layout(with: addressLabel).centerY()

        distanceLabel.layout(with: scrollViewContent).trailing(by: -Metrics.margin)
        distanceLabel.layout(with: addressLabel).centerY()
        
        mapViewContainer.layout(with: scrollViewContent).fillHorizontal(by: Metrics.margin)
        mapViewContainer.layout().height(Layout.Map.height)
        mapViewContainer.layout(with: distanceLabel).below(by: Metrics.shortMargin)
        
        bannerContainerViewLeftConstraint = bannerContainerView.leadingAnchor.constraint(equalTo: scrollViewContent.leadingAnchor)
        bannerContainerViewRightConstraint = bannerContainerView.trailingAnchor.constraint(equalTo: scrollViewContent.trailingAnchor)
        bannerContainerViewHeightConstraint = bannerContainerView.heightAnchor.constraint(equalToConstant: 0)
        
        bannerContainerViewLeftConstraint?.isActive = true
        bannerContainerViewRightConstraint?.isActive = true
        bannerContainerViewHeightConstraint?.isActive = true
        
        bannerContainerView.layout(with: mapViewContainer).below(by: Metrics.margin)
        
        socialShareContainer.layout(with: scrollViewContent)
            .fillHorizontal(by: Metrics.margin).bottom(by: -Metrics.shortMargin)
        socialShareContainer.layout().height(Layout.SocialShare.height)
        
        shareViewToMapTopConstraint = socialShareContainer.topAnchor.constraint(greaterThanOrEqualTo: mapViewContainer.bottomAnchor, constant: Layout.SocialShare.bottom)
        shareViewToBannerTopConstraint = socialShareContainer.topAnchor.constraint(equalTo: bannerContainerView.bottomAnchor, constant: Metrics.margin)
        shareViewToMapTopConstraint?.isActive = true
        shareViewToBannerTopConstraint?.isActive = true
        
        socialShareTitleLabel.layout(with: socialShareContainer).fillHorizontal().top()
        socialShareView.layout(with: socialShareContainer).fillHorizontal()
        socialShareView.layout(with: socialShareTitleLabel).below(by: Metrics.shortMargin)

        //  DragView
        
        dragView.layout(with: self)
            .bottom().centerX()
        dragButton.layout().height(Layout.DragView.height)
        dragButton.layout(with: dragView)
            .centerX()
            .top(by: Metrics.veryShortMargin).bottom(by: -Layout.DragView.bottom)
        
        dragView.layout(with: dragButton).proportionalWidth()
        
        dragViewTitle.layout(with: dragButton)
            .leading(by: Metrics.margin).fillVertical()
        dragViewImage.layout(with: dragButton).trailing(by: -Metrics.margin).centerY()
        dragViewImage.layout(with: dragViewTitle).toLeft(by: Metrics.veryShortMargin)
 
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
                shareViewToMapTopConstraint?.isActive = true
                shareViewToBannerTopConstraint?.isActive = true
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
    }

    func dismissed() {
        scrollView.contentOffset = .zero
        descriptionLabel.collapsed = true
    }

    deinit {
        // MapView is a shared instance and all references must be removed
        cleanMapView()
    }

    func updateBottomAreaMargin(with value: CGFloat) {
        self.scrollViewBottomConstraint?.constant = value
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
        guard mapView.superview != container else { return }
        setupMapView(inside: container)
    }
    
    func setupMapView(inside container: UIView) {
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-SetupMapView-start")
        mapView.clipsToBounds = true
        layoutMapView(inside: container)
        addMapGestures()
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-SetupMapView-end")
    }

    private func setupMapRx(viewModel: ListingCarouselViewModel) {

        let productLocation = viewModel.productInfo.asObservable().map { $0?.location }.unwrap()
        let mapInfo = Observable.combineLatest(productLocation.asObservable(),
                                               viewModel.showExactLocationOnMap.asObservable())
        mapInfo.bind { [weak self] (coordinate, showExactLocation) in
            guard let strongSelf = self else { return }
            strongSelf.addRegion(with: coordinate, zoomBlocker: true)
            strongSelf.setupMapExpanded(false)
            if showExactLocation {
                strongSelf.mapPinCustomAnnotation = MKPointAnnotation()
                strongSelf.mapPinCustomAnnotation?.coordinate = coordinate.coordinates2DfromLocation()
                if let mapAnnotation = strongSelf.mapPinCustomAnnotation {
                    strongSelf.mapView.addAnnotation(mapAnnotation)
                }
            } else {
                strongSelf.mapView.removeAnnotations(strongSelf.mapView.annotations)
                strongSelf.mapPinCustomAnnotation = nil
                strongSelf.locationZone = MKCircle(center:coordinate.coordinates2DfromLocation(),
                                                   radius: SharedConstants.accurateRegionRadius)
            }
            }.disposed(by: disposeBag)
    }

    private func layoutMapView(inside container: UIView) {
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-LayoutMapView-start")
        if mapView.superview != nil {
            mapView.removeFromSuperview()
        }
        container.addSubviewForAutoLayout(mapView)

        mapView.layout(with: container)
            .fillHorizontal()
            .top()
            .bottom(by: -Metrics.shortMargin)

        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-LayoutMapView-end")
    }
    
    private func addMapGestures() {
        mapView.removeAllGestureRecognizers()
        mapViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap))
        guard let mapViewTapGesture = mapViewTapGesture else { return }
        mapView.addGestureRecognizer(mapViewTapGesture)
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
        vmRegion = MKCoordinateRegionMakeWithDistance(clCoordinate, SharedConstants.accurateRegionRadius*2, SharedConstants.accurateRegionRadius*2)
        guard let region = vmRegion else { return }
        mapView.setRegion(region, animated: false)
        
        if zoomBlocker {
            mapZoomBlocker = MapZoomBlocker(mapView: mapView, minLatDelta: region.span.latitudeDelta,
                                            minLonDelta: region.span.longitudeDelta)
            mapZoomBlocker?.delegate = self
        }
    }
    
    private func expandMap() {
        guard !mapExpanded else { return }
        addSubview(mapViewContainerExpandable)
        mapViewContainerExpandable.frame = convert(mapViewContainer.frame, from: scrollViewContent)
        layoutMapView(inside: mapViewContainerExpandable)

        if let locationZone = self.locationZone, mapPinCustomAnnotation == nil {
            mapView.add(locationZone)
        }

        self.delegate?.request(fullScreen: true)
        var expandedFrame = mapViewContainerExpandable.frame
        expandedFrame.origin.y = Layout.BigMap.margin
        expandedFrame.size.height = height - (Layout.BigMap.margin + Layout.BigMap.bottom)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mapViewContainerExpandable.frame = expandedFrame
            self?.mapViewContainerExpandable.layoutIfNeeded()
            }, completion: { [weak self] completed in
                self?.setupMapExpanded(true)
        })
    }
    
    @objc func compressMap() {
        guard mapExpanded else { return }

        self.delegate?.request(fullScreen: false)
        let compressedFrame = convert(mapViewContainer.frame, from: scrollViewContent)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mapViewContainerExpandable.frame = compressedFrame
            self?.mapViewContainerExpandable.layoutIfNeeded()
            }, completion: { [weak self] completed in
                guard let strongSelf = self else { return }
                strongSelf.setupMapExpanded(false)
                if let locationZone = strongSelf.locationZone {
                    strongSelf.mapView.remove(locationZone)
                }
                strongSelf.layoutMapView(inside: strongSelf.mapViewContainer)
                strongSelf.mapViewContainerExpandable.removeFromSuperview()
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

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let mapPinView = mapView.dequeueReusableAnnotationView(withIdentifier: ListingCarouselMoreInfoView.mapPinAnnotationReuseId) else {
            let newMapPinView = MKAnnotationView(annotation: annotation,
                                                 reuseIdentifier: ListingCarouselMoreInfoView.mapPinAnnotationReuseId)
            newMapPinView.image = R.Asset.IconsButtons.Map.mapPin.image
            return newMapPinView
        }
        mapPinView.annotation = annotation
        return mapPinView
    }
}

extension ListingCarouselMoreInfoView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomOverScroll = max(scrollView.contentOffset.y - bottomScrollLimit, 0)
        visualEffectViewBottom?.constant = -bottomOverScroll
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

private extension ListingCarouselMoreInfoView {

    func setupAttributeGridView(withTitle title: String?,
                                items: [ListingAttributeGridItem]?,
                                showExtraCardFields: Bool = false) {
        guard let items = items, items.count > 0, showExtraCardFields else {
                attributeGridViewHeightConstraint?.constant = 0.0
                return
        }
        
        attributeGridViewHeightConstraint?.constant = Layout.AttributeGrid.height
        attributeGridView.setup(withTitle: title,
                                items: items,
                                tapAction: { [weak self] in
                                    guard let wself = self,
                                        let items = wself.viewModel?.productInfo.value?.attributeGridItems else { return }
                                    wself.viewModel?.listingAttributeGridTapped(forItems: items)
        })
    }

    func setupSocialShareView() {
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-setupSocialShareView-start")
        socialShareView.delegate = self
        report(AppReport.uikit(error: .breadcrumb), message: "MoreInfoView-setupSocialShareView-end")
    }

    func hideAdsBanner() {
        bannerContainerView.isHidden = true
        bannerContainerViewHeightConstraint?.constant = 0
        if shareViewToMapTopConstraint?.isActive ?? false {
            shareViewToMapTopConstraint?.constant = Layout.SocialShare.top
        }
    }

    // MARK: > Configuration (each view model)

    func setupContentRx(viewModel: ListingCarouselViewModel) {

        let statusAndChat = Observable.combineLatest(viewModel.status.asObservable(), viewModel.directChatEnabled.asObservable()) { ($0, $1) }
        statusAndChat.bind { [weak self] (status, chatEnabled) in
            self?.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                                         bottom: status.scrollBottomInset(chatEnabled: chatEnabled), right: 0)
        }.disposed(by: disposeBag)
        
        let showCarExtraFields = viewModel.extraFieldsGridEnabled
        let showPaymentFrequency = viewModel.shouldShowPaymentFrequency
        
        viewModel.productInfo.asObservable().unwrap().bind { [weak self] info in
            self?.titleLabel.attributedText = info.styledTitle?.stringByRemovingLinks
            self?.updatePriceLabel(withInfo: info, shouldShowPaymentFrequency: showPaymentFrequency)
            self?.autoTitleLabel.text = info.titleAutoGenerated ? R.Strings.productAutoGeneratedTitleLabel : nil
            self?.transTitleLabel.text = info.titleAutoTranslated ? R.Strings.productAutoGeneratedTranslatedTitleLabel : nil
            self?.addressLabel.text = info.address
            self?.distanceLabel.text = info.distance
            self?.descriptionLabel.mainAttributedText = info.styledDescription
            self?.descriptionLabel.setNeedsLayout()
            self?.updateTags(tags: info.attributeTags)
            self?.setupAttributeGridView(withTitle: info.attributeGridTitle,
                                         items: info.attributeGridItems,
                                         showExtraCardFields: showCarExtraFields)
        }.disposed(by: disposeBag)
    }
    
    private func updatePriceLabel(withInfo info: ListingVMProductInfo,
                                  shouldShowPaymentFrequency: Bool) {
        guard shouldShowPaymentFrequency,
            let priceAttributedString = priceAttributedString(forPrice: info.price,
                                                              paymentFrequency: info.paymentFrequency) else {
            priceLabel.text = info.price
            return
        }
        
        priceLabel.attributedText = priceAttributedString
    }
    
    private func priceAttributedString(forPrice price: String,
                                       paymentFrequency: String?) -> NSAttributedString? {
        guard let paymentFrequency = paymentFrequency else { return nil }
        
        let text = "\(price) \(paymentFrequency)"
        return text.bifontAttributedText(highlightedText: paymentFrequency,
                                         mainFont: .productPriceFont,
                                         mainColour: .white,
                                         otherFont: .productTitleFont,
                                         otherColour: .white)
    }
    
    private func updateTags(tags: [String]?) {
        tagCollectionViewModel.tags = tags ?? []
        tagCollectionView.reloadData()
    }
    
    func setupStatsRx(viewModel: ListingCarouselViewModel) {
        let productCreation = viewModel.productInfo.asObservable().map { $0?.creationDate }
        let statsAndCreation = Observable.combineLatest(viewModel.listingStats.asObservable().unwrap(), productCreation) { ($0, $1) }
        let statsViewVisible = statsAndCreation.map { (stats, creation) in
            return stats.viewsCount >= SharedConstants.minimumStatsCountToShow || stats.favouritesCount >= SharedConstants.minimumStatsCountToShow || creation != nil
        }
        statsViewVisible.asObservable().distinctUntilChanged().bind { [weak self] visible in
            self?.statsContainerViewHeightConstraint?.constant = visible ? Layout.Stats.height : 0
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

            bannerContainerView.addSubviewForAutoLayout(dfpBanner)
            dfpBanner.layout(with: bannerContainerView).top().bottom().centerX()

            dfpBanner.delegate = self
    }

    func loadDFPRequest() {
        bannerContainerViewHeightConstraint?.constant = kGADAdSizeLargeBanner.size.height
        shareViewToMapTopConstraint?.isActive = true
        shareViewToBannerTopConstraint?.isActive = false

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
        bannerContainerViewHeightConstraint?.constant = sizeFromAdSize.height
        if let sideMargin = viewModel?.sideMargin {
            bannerContainerViewLeftConstraint?.constant = sideMargin
            bannerContainerViewRightConstraint?.constant = sideMargin
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

        bannerContainerViewHeightConstraint?.constant = bannerView.height
        shareViewToMapTopConstraint?.constant = bannerView.height + Layout.SocialShare.top

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
        bannerContainerViewHeightConstraint?.constant = 0
        bannerContainerViewLeftConstraint?.constant = 0
        bannerContainerViewRightConstraint?.constant = 0

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
        viewModel?.descriptionURLPressed(URL)
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
    private func setAccessibilityIds() {
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

private struct Layout {
    struct VisualEffect {
        static let top: CGFloat = -500
    }
    struct ScrollView {
        static let bottom: CGFloat = 88
        static let top: CGFloat = 64
    }
    struct AttributeGrid {
        static let height: CGFloat = 150
    }
    struct Map {
        static let height: CGFloat = 150
    }
    struct BigMap {
        static let margin: CGFloat = 85
        static let bottom: CGFloat = 85
    }
    struct DragView {
        static let height: CGFloat = 30
        static let bottom: CGFloat = 7
        static let imageSize: CGFloat = 24
    }
    struct Stats {
        static let height: CGFloat = 24
    }
    struct SocialShare {
        static let height: CGFloat = 135
        static let bottom: CGFloat = 30
        static let top: CGFloat = 30
        static let buttonSideSort: CGFloat = 50
        static let buttonSideLong: CGFloat = 56
        static let columns = 5
    }
}
