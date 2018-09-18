import LGCoreKit
import RxSwift
import RxCocoa
import LGComponents
import GoogleMobileAds

final class ListingCarouselViewController: KeyboardViewController, AnimatableTransition {
    
    private struct Layout {
        static let pageControlArbitraryTopMargin: CGFloat = 40
        static let pageControlArbitraryWidth: CGFloat = 50
        static let videoProgressViewHeight: CGFloat = 4.0
    }
    
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonBottom: LetgoButton!
    @IBOutlet weak var buttonBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var buttonBottomRightMarginToSuperviewConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonCall: LetgoButton!
    @IBOutlet weak var buttonCallWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonCallRightMarginToSuperviewConstraint: NSLayoutConstraint!

    @IBOutlet weak var buttonTop: LetgoButton!
    @IBOutlet weak var buttonTopHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonTopBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatContainer: ListingCarouselChatContainerView!
    @IBOutlet weak var chatContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var chatContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var gradientShadowView: UIView!
    @IBOutlet weak var gradientShadowBottomView: UIView!

    @IBOutlet weak var favoriteButtonTopAligment: NSLayoutConstraint!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareButtonTopAlignment: NSLayoutConstraint!
    
    @IBOutlet weak var productStatusView: UIView!
    @IBOutlet weak var productStatusViewTopAlignment: NSLayoutConstraint!
    @IBOutlet weak var productStatusLabel: UILabel!
    @IBOutlet weak var productStatusImageView: UIImageView!
    @IBOutlet weak var productStatusImageViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var productStatusImageViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var productStatusImageViewWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var directChatTable: CustomTouchesTableView!

    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var bannerContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerContainerHeightConstraint: NSLayoutConstraint!

    private let userView: UserView
    private let fullScreenAvatarEffectView: UIVisualEffectView
    private let fullScreenAvatarView: UIImageView
    private var fullScreenAvatarWidth: NSLayoutConstraint?
    private var fullScreenAvatarHeight: NSLayoutConstraint?
    private var fullScreenAvatarTop: NSLayoutConstraint?
    private var fullScreenAvatarLeft: NSLayoutConstraint?
    private let viewModel: ListingCarouselViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private var userViewBottomConstraint: NSLayoutConstraint?
    private var userViewRightConstraint: NSLayoutConstraint?

    private let mainViewBlurEffectView: UIVisualEffectView

    private var userViewRightMargin: CGFloat = CarouselUI.itemsMargin {
        didSet {
            userViewRightConstraint?.constant = -userViewRightMargin
        }
    }

    private var bottomItemsMargin: CGFloat = CarouselUI.itemsMargin {
        didSet {
            chatContainerBottomConstraint?.constant = bottomItemsMargin
        }
    }
    private var bannerBottom: CGFloat = -CarouselUI.bannerHeight {
        didSet {
            bannerContainerBottomConstraint?.constant = contentBottomMargin + bannerBottom
        }
    }
    private var contentBottomMargin: CGFloat = 0 {
        didSet {
            bannerContainerBottomConstraint?.constant = contentBottomMargin + bannerBottom
        }
    }
    private var bannerHeight: CGFloat = CarouselUI.bannerHeight {
        didSet {
            bannerContainerHeightConstraint?.constant = bannerHeight
        }
    }

    fileprivate let pageControl: UIView & PageControlRepresentable
    private var pageControlWidth: NSLayoutConstraint?
    private var pageControlTopMargin: NSLayoutConstraint?

    private var moreInfoTooltip: Tooltip?

    private let collectionContentOffset = Variable<CGPoint>(CGPoint.zero)
    private let itemsAlpha = Variable<CGFloat>(1)
    private let cellZooming = Variable<Bool>(false)
    private let cellAnimating = Variable<Bool>(false)

    private var activeDisposeBag = DisposeBag()
    private var productInfoConstraintOffset: CGFloat = 0

    private var productOnboardingView: ListingDetailOnboardingView?
    private var didSetupAfterLayout = false

    private var shouldShowProgressView: Bool = false {
        didSet {
            progressView.progress = 0
            progressView.isHidden = !shouldShowProgressView
        }
    }
    private let progressView: UIProgressView = {
        let bar = UIProgressView()
        bar.progressTintColor = .gray
        bar.trackTintColor = UIColor.black.withAlphaComponent(0.5)
        bar.layer.cornerRadius = Layout.videoProgressViewHeight / 2.0
        bar.clipsToBounds = true
        return bar
    }()

    private let moreInfoView = ListingCarouselMoreInfoView(frame: .zero)
    private let moreInfoAlpha = Variable<CGFloat>(1)
    private let moreInfoState = Variable<MoreInfoState>(.hidden)

    private var directAnswersBottom = NSLayoutConstraint()

    private var bumpUpBanner = BumpUpBanner()

    let animator: PushAnimator?
    var pendingMovement: CarouselMovement?

    private let carouselImageDownloader: ImageDownloaderType
    private let imageDownloader: ImageDownloaderType

    private var bottomScrollLimit: CGFloat {
        return max(0, collectionView.contentSize.height - collectionView.height + collectionView.contentInset.bottom)
    }
    
    private var shouldHideStatusBar = true

    private var interstitial: GADInterstitial?
    private var firstAdShowed = false
    private var lastIndexAd = -1
    
    // MARK: - Lifecycle

    convenience init(viewModel: ListingCarouselViewModel, pushAnimator: ListingCarouselPushAnimator?) {
        self.init(viewModel:viewModel,
                  pushAnimator: pushAnimator,
                  imageDownloader: ImageDownloader.sharedInstance,
                  carouselImageDownloader: ImageDownloader.make(usingImagePool: true))
    }

    init(viewModel: ListingCarouselViewModel,
         pushAnimator: ListingCarouselPushAnimator?,
         imageDownloader: ImageDownloaderType,
         carouselImageDownloader: ImageDownloaderType) {
        self.viewModel = viewModel
        self.userView = UserView.userView(.withProductInfo)
        let blurEffect = UIBlurEffect(style: .dark)
        self.fullScreenAvatarEffectView = UIVisualEffectView(effect: blurEffect)
        self.fullScreenAvatarView = UIImageView(frame: CGRect.zero)
        self.animator = pushAnimator
        
        if viewModel.shouldShowScrollingPageControl {
            self.pageControl = AnnotatedScrollingPageControlView(frame: CGRect.zero)
        } else {
            self.pageControl = UIPageControl(frame: CGRect.zero)
        }
        
        self.imageDownloader = imageDownloader
        self.carouselImageDownloader = carouselImageDownloader
        let mainBlurEffect = UIBlurEffect(style: .light)
        self.mainViewBlurEffectView = UIVisualEffectView(effect: mainBlurEffect)
        super.init(viewModel: viewModel, nibName: "ListingCarouselViewController", statusBarStyle: .lightContent,
                   navBarBackgroundStyle: .transparent(substyle: .dark), swipeBackGestureEnabled: false)
        self.viewModel.delegate = self
        hidesBottomBarWhenPushed = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientShadowView.layer.sublayers?.forEach{ $0.frame = gradientShadowView.bounds }
        gradientShadowBottomView.layer.sublayers?.forEach{ $0.frame = gradientShadowBottomView.bounds }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupGradientView()
        setupCollectionRx()
        setupZoomRx()
        setupProgressViewButton()
        setAccessibilityIds()
        setupInterstitial()
    }

    private func setupProgressViewButton() {
        view.addSubviewForAutoLayout(progressView)
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CarouselUI.itemsMargin),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CarouselUI.itemsMargin),
            progressView.bottomAnchor.constraint(equalTo: userView.topAnchor, constant: -CarouselUI.itemsMargin),
            progressView.heightAnchor.constraint(equalToConstant: Layout.videoProgressViewHeight)
            ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showStatusBar()
        if moreInfoState.value == .shown {
            moreInfoView.viewWillShow()
        }
    }

    override func viewDidFirstAppear(_ animated: Bool) {
        super.viewDidFirstAppear(animated)

        switch viewModel.actionOnFirstAppear {
        case .showKeyboard:
            chatContainer.becomeFirstResponder()
        case .showShareSheet:
            viewModel.shareButtonPressed()
        case let .triggerBumpUp(bumpUpProductData,
                                maxCountdown,
                                bumpUpType,
                                triggerBumpUpSource,
                                typePage):
            viewModel.showBumpUpView(bumpUpProductData: bumpUpProductData,
                                     maxCountdown: maxCountdown,
                                     bumpUpType: bumpUpType,
                                     bumpUpSource: triggerBumpUpSource,
                                     typePage: typePage)
        case .triggerMarkAsSold:
            viewModel.currentListingViewModel?.markAsSold()
        case .edit:
            viewModel.currentListingViewModel?.editListing()
        default:
            break
        }

    }

    override func viewWillDisappearToBackground(_ toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)
        removeIgnoreTouchesForMoreInfo()
        if toBackground {
            closeBumpUpBanner()
        }
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        guard didSetupAfterLayout else { return }
        // ABIOS-2720
        // Force tabBar to hide when view appears from background.
        self.tabBarController?.setTabBarHidden(true, animated: false)
        addIgnoreTouchesForMoreInfo()
    }

    /*
     We need to setup some properties after we are sure the view has the final frame, to do that
     the animator will tell us when the view has a valid frame to configure the elements.
     `viewDidLayoutSubviews` will be called multiples times, we must assure the setup is done once only.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !didSetupAfterLayout else { return } // Already setup, just do nothing
        if let animator = animator {
            if animator.toViewValidatedFrame {
                setupAfterLayout(backgroundImage: animator.fromViewSnapshot, activeAnimator: animator.active)
            }
        } else {
            setupAfterLayout(backgroundImage: nil, activeAnimator: false)
        }
        productStatusView.setRoundedCorners()
    }

    /*
     After the initial layout setup the safeAreaInsets might change so we need to update
     the more info view constraints. I.e. the first time this Carousel is launched
     */
    override func viewSafeAreaInsetsDidChange() {
        guard moreInfoState.value == .hidden, didSetupAfterLayout else { return }
        resetMoreInfoState()
    }

    private func setupAfterLayout(backgroundImage: UIImage?, activeAnimator: Bool) {
        didSetupAfterLayout = true
        if !activeAnimator {
            //Usually animator takes care of it, but if animator couldn't work, we should hide it manually
            tabBarController?.setTabBarHidden(true, animated: false)
        }
        imageBackground.image = backgroundImage
        flowLayout.itemSize = view.bounds.size
        setupAlphaRxBindings()

        collectionView.reloadData()
        let startIndexPath = IndexPath(item: viewModel.startIndex, section: 0)
        collectionView.scrollToItem(at: startIndexPath, at: .right, animated: false)

        setupMoreInfo()
        setupMoreInfoDragging()
        setupMoreInfoTooltip()
        setupOverlayRxBindings()

        resetMoreInfoState()
    }


    // MARK: Setup

    func addSubviews() {
        imageBackground.addSubviewForAutoLayout(mainViewBlurEffectView)
        view.addSubviewsForAutoLayout([pageControl, fullScreenAvatarEffectView, userView, fullScreenAvatarView])
    }

    func setupUI() {
        addSubviews()
        productStatusImageView.image = R.Asset.Monetization.icLightning.image
        
        if !isSafeAreaAvailable {
            favoriteButtonTopAligment.constant = 55
            shareButtonTopAlignment.constant = 70
            productStatusViewTopAlignment.constant = 80
        }
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0

        collectionView.dataSource = self
        collectionView.delegate = self
        //Duplicating registered cells to avoid reuse of colindant cells
        registerListingCarouselCells()
        collectionView.isDirectionalLockEnabled = true
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        automaticallyAdjustsScrollViewInsets = false

        setupPageControlConstraints()

        mainViewBlurEffectView.layout(with: imageBackground).fill()
        fullScreenAvatarEffectView.layout(with: view).fill()

        userView.delegate = self

        userView.layout().height(CarouselUI.buttonHeight)
        userView.layout(with: view)
            .leading(by: CarouselUI.itemsMargin)
            .trailing(by: CarouselUI.itemsMargin, constraintBlock: { [weak self] in
                self?.userViewRightConstraint = $0
            })
        userView.layout(with: buttonTop)
            .above(by: 0, constraintBlock: nil)

        // UserView effect
        fullScreenAvatarEffectView.alpha = 0
        fullScreenAvatarView.clipsToBounds = true
        fullScreenAvatarView.contentMode = .scaleAspectFill
        fullScreenAvatarView.alpha = 0
        let fullAvatarWidth = NSLayoutConstraint(item: fullScreenAvatarView, attribute: .width, relatedBy: .equal, toItem: nil,
                                                 attribute: .notAnAttribute, multiplier: 1, constant: 0)
        fullScreenAvatarWidth = fullAvatarWidth
        let fullAvatarHeight = NSLayoutConstraint(item: fullScreenAvatarView, attribute: .height, relatedBy: .equal, toItem: nil,
                                                  attribute: .notAnAttribute, multiplier: 1, constant: 0)
        fullScreenAvatarHeight = fullAvatarHeight
        fullScreenAvatarView.addConstraints([fullAvatarWidth, fullAvatarHeight])
        let fullAvatarTop = NSLayoutConstraint(item: fullScreenAvatarView, attribute: .top, relatedBy: .equal,
                                               toItem: view, attribute: .top, multiplier: 1, constant: 0)
        fullScreenAvatarTop = fullAvatarTop
        let fullAvatarLeft = NSLayoutConstraint(item: fullScreenAvatarView, attribute: .left, relatedBy: .equal,
                                                toItem: view, attribute: .left, multiplier: 1, constant: 0)
        fullScreenAvatarLeft = fullAvatarLeft
        view.addConstraints([fullAvatarTop, fullAvatarLeft])
        userView.showShadow(false)

        productStatusLabel.textColor = UIColor.soldColor
        productStatusLabel.font = UIFont.productStatusSoldFont

        setupCallButton()

        CarouselUIHelper.setupShareButton(shareButton,
                                          text: R.Strings.productShareNavbarButton,
                                          icon: R.Asset.IconsButtons.icShare.image)

        mainResponder = chatContainer
        setupDirectMessages()
        setupBumpUpBanner()
    }
    
    private func setupPageControlConstraints() {
        
        if viewModel.shouldShowScrollingPageControl {
            
            NSLayoutConstraint.activate([
                pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                     constant: CarouselUI.ProPageControlUI.proPageControlLeadingConstant),
                pageControl.heightAnchor.constraint(equalToConstant: CarouselUI.ProPageControlUI.proPageControlHeight),
                pageControl.widthAnchor.constraint(equalToConstant: CarouselUI.ProPageControlUI.proPageControlWidth),
                pageControl.topAnchor.constraint(equalTo: safeTopAnchor,
                                                 constant: CarouselUI.ProPageControlUI.proPageControlTopConstant)
                ])
        } else {
            let pcWidth = pageControl.widthAnchor.constraint(equalToConstant: Layout.pageControlArbitraryWidth)
            let pcTopMargin = pageControl.centerYAnchor.constraint(equalTo: safeTopAnchor,
                                                                   constant: Layout.pageControlArbitraryTopMargin)
            
            NSLayoutConstraint.activate([
                pageControl.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: CarouselUI.pageControlMargin),
                pageControl.heightAnchor.constraint(equalToConstant: Metrics.bigMargin),
                pcTopMargin, pcWidth
                ])
            pageControlWidth = pcWidth
            pageControlTopMargin = pcTopMargin
            
            pageControl.cornerRadius = CarouselUI.pageControlWidth/2
            pageControl.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            pageControl.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            pageControl.currentPageIndicatorTintColor = .white
            pageControl.hidesForSinglePage = true
        }
    }

    private func setupCallButton() {
        buttonCall.setStyle(.primary(fontSize: .big))
        buttonCall.setTitle(R.Strings.productProfessionalCallButton, for: .normal)
        buttonCall.setImage(R.Asset.Monetization.icPhoneCall.image, for: .normal)
        buttonCall.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Metrics.shortMargin, bottom: 0, right: 0)
        buttonCall.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.shortMargin, bottom: 0, right: 0)
        buttonCall.isHidden = true
        buttonCall.addTarget(self, action: #selector(callButtonPressed), for: .touchUpInside)
    }

    func setupBumpUpBanner() {
        bumpUpBanner.delegate = self
        bannerContainer.addSubview(bumpUpBanner)
        bumpUpBanner.translatesAutoresizingMaskIntoConstraints = false
        bumpUpBanner.layout(with: bannerContainer).fill()
        bannerContainer.isHidden = true
    }

    private func setupMoreInfo() {
        view.addSubview(moreInfoView)
        moreInfoView.layout(with: view).fillHorizontal().fillVertical()
        moreInfoAlpha.asObservable().bind(to: moreInfoView.rx.alpha).disposed(by: disposeBag)
        moreInfoAlpha.asObservable().bind(to: moreInfoView.dragView.rx.alpha).disposed(by: disposeBag)

        view.bringSubview(toFront: buttonBottom)
        view.bringSubview(toFront: buttonCall)
        view.bringSubview(toFront: chatContainer)
        view.bringSubview(toFront: bannerContainer)
        view.bringSubview(toFront: fullScreenAvatarEffectView)
        view.bringSubview(toFront: fullScreenAvatarView)
        view.bringSubview(toFront: directChatTable)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMoreInfo))
        moreInfoView.addGestureRecognizer(tapGesture)
    }

    private func setupNavigationBar() {
        let backIconImage = R.Asset.IconsButtons.icCloseCarousel.image
        let backButton = UIBarButtonItem(image: backIconImage, style: UIBarButtonItemStyle.plain,
                                         target: self, action: #selector(backButtonClose))
        backButton.set(accessibilityId: .listingCarouselNavBarCloseButton)
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonClose() {
        close()
    }

    private func close() {
        if moreInfoView.frame.origin.y < 0 {
            closeBumpUpBanner()
            viewModel.close()
        } else {
            moreInfoView.mapExpanded ? compressMap() : hideMoreInfo()
        }
    }

    @objc dynamic private func callButtonPressed() {
        viewModel.callSeller()
    }

    private func setupGradientView() {
        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.black, alphas:[0.4, 0], locations: [0, 1])
        shadowLayer.frame = gradientShadowView.bounds
        gradientShadowView.layer.insertSublayer(shadowLayer, at: 0)

        let shadowLayer2 = CAGradientLayer.gradientWithColor(UIColor.black, alphas:[0, 0.4], locations: [0, 1])
        shadowLayer.frame = gradientShadowBottomView.bounds
        gradientShadowBottomView.layer.insertSublayer(shadowLayer2, at: 0)
    }

    private func setupCollectionRx() {
        viewModel.objectChanges.observeOn(MainScheduler.instance).bind { [weak self] change in
            self?.collectionView.reloadData()
        }.disposed(by: disposeBag)
    }

    private func setupZoomRx() {
        cellZooming.asObservable().distinctUntilChanged().bind { [weak self] zooming in
            UIView.animate(withDuration: 0.3) {
                let alphaValue: CGFloat = zooming ? 0 : 1
                self?.itemsAlpha.value = alphaValue
                self?.moreInfoAlpha.value = alphaValue
                self?.moreInfoTooltip?.alpha = alphaValue
                self?.updateNavigationBarAlpha(alphaValue)
            }
            }.disposed(by: disposeBag)
    }
    
    private func setupInterstitial() {
        interstitial = viewModel.createAndLoadInterstitial()
        if let interstitial = interstitial {
            interstitial.delegate = self
        }
    }
    
    private func setupAlphaRxBindings() {
        itemsAlpha.asObservable().bind(to: buttonBottom.rx.alpha).disposed(by: disposeBag)
        itemsAlpha.asObservable().bind(to: buttonTop.rx.alpha).disposed(by: disposeBag)
        itemsAlpha.asObservable().bind(to: userView.rx.alpha).disposed(by: disposeBag)
        itemsAlpha.asObservable().bind(to: buttonCall.rx.alpha).disposed(by: disposeBag)
        itemsAlpha.asObservable().bind(to: progressView.rx.alpha).disposed(by: disposeBag)

        itemsAlpha.asObservable().bind { [weak self] itemsAlpha in
            self?.pageControl.alpha = itemsAlpha
        }.disposed(by: disposeBag)

        itemsAlpha.asObservable().bind(to: productStatusView.rx.alpha).disposed(by: disposeBag)
        itemsAlpha.asObservable().bind(to: directChatTable.rx.alpha).disposed(by: disposeBag)
        itemsAlpha.asObservable().bind(to: chatContainer.rx.alpha).disposed(by: disposeBag)
        itemsAlpha.asObservable().bind(to: shareButton.rx.alpha).disposed(by: disposeBag)
        itemsAlpha.asObservable().bind(to: bannerContainer.rx.alpha).disposed(by: disposeBag)

        Observable.combineLatest(viewModel.favoriteButtonState.asObservable(), itemsAlpha.asObservable()) { ($0, $1) }
            .bind { [weak self] (buttonState, itemsAlpha) in
                guard let strongButton = self?.favoriteButton else { return }
                guard itemsAlpha != 0 else {
                    strongButton.alpha = 0
                    return
                }
                switch buttonState {
                case .hidden:
                    strongButton.isHidden = true
                case .enabled:
                    strongButton.isHidden = false
                    strongButton.alpha = itemsAlpha
                case .disabled, .loading:
                    strongButton.isHidden = false
                    strongButton.alpha = 0.6
                }
            }.disposed(by: disposeBag)

        let width = view.bounds.width
        let midPoint = width/2
        let minMargin = midPoint * 0.15

        let alphaSignal: Observable<CGFloat> = collectionContentOffset.asObservable()
            .map {
                let midValue = fabs($0.x.truncatingRemainder(dividingBy: width) - midPoint)
                if midValue <= minMargin { return 0 }
                if midValue >= (midPoint-minMargin) { return 1}
                let newValue = (midValue - minMargin) / (midPoint - minMargin*2)
                return newValue
        }

        alphaSignal.bind(to: itemsAlpha).disposed(by: disposeBag)
        alphaSignal.bind(to: moreInfoAlpha).disposed(by: disposeBag)

        alphaSignal.bind { [weak self] alpha in
            self?.moreInfoTooltip?.alpha = alpha
            self?.updateNavigationBarAlpha(alpha)
        }.disposed(by: disposeBag)

        var indexSignal: Observable<Int> = collectionContentOffset.asObservable().map { Int(($0.x + midPoint) / width) }

        if viewModel.startIndex != 0 {
            indexSignal = indexSignal.skip(1)
        }
        indexSignal
            .distinctUntilChanged()
            .bind { [weak self] index in
                guard let strongSelf = self else { return }
                let movement: CarouselMovement
                if let pendingMovement = strongSelf.pendingMovement {
                    movement = pendingMovement
                    strongSelf.pendingMovement = nil
                } else if index > strongSelf.viewModel.currentIndex {
                    movement = .swipeRight
                } else if index < strongSelf.viewModel.currentIndex {
                    movement = .swipeLeft
                } else {
                    movement = .initial
                }
                if movement != .initial {
                    self?.viewModel.moveToProductAtIndex(index, movement: movement)
                }
                if let rootViewController = self?.parent, movement == .tap || movement == .swipeRight {
                    self?.viewModel.presentInterstitial(self?.interstitial, index: index, fromViewController: rootViewController)
                }
                if movement == .tap {
                    self?.finishedTransition()
                }
                self?.shouldShowProgressView = self?.viewModel.itemIsPlayable(at: 0) ?? false
                strongSelf.returnCellToFirstImage()
            }
            .disposed(by: disposeBag)

        //Event when scroll reaches one entire page (alpha == 1) so that we can delay some tasks until then.
        alphaSignal.map { $0 == 1 }.distinctUntilChanged().filter { $0 }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .bind { [weak self] _ in
                self?.finishedTransition()
            }.disposed(by: disposeBag)
    }

    private func updateNavigationBarAlpha(_ alpha: CGFloat) {
        navigationItem.leftBarButtonItems?.forEach { $0.customView?.alpha = alpha }
        navigationItem.rightBarButtonItems?.forEach { $0.customView?.alpha = alpha }
    }

    private func returnCellToFirstImage() {
        let visibleCells = collectionView.visibleCells.compactMap { $0 as? ListingCarouselCell }
        visibleCells.filter {
            guard let index = collectionView.indexPath(for: $0) else { return false }
            return index.row != viewModel.currentIndex
            }.forEach { $0.returnToFirstImage() }
    }
    
    // MARK: - Status Bar style
    
    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func showStatusBar() {
        if shouldHideStatusBar {
            shouldHideStatusBar = false
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}

// MARK: > Configure Carousel With ListingCarouselViewModel

extension ListingCarouselViewController {

    fileprivate func setupOverlayRxBindings() {
        setupMoreInfoRx()
        setupPageControlRx()
        setupUserInfoRx()
        setupNavbarButtonsRx()
        setupBottomButtonsRx()
        setupProductStatusLabelRx()
        setupDirectChatElementsRx()
        setupFavoriteButtonRx()
        setupShareButtonRx()
        setupBumpUpBannerRx()
        setupUserInteractionRxBindings()
    }

    private func setupMoreInfoRx() {
        moreInfoView.setupWith(viewModel: viewModel)
        moreInfoState.asObservable().bind(to: viewModel.moreInfoState).disposed(by: disposeBag)
    }
    
    private func setupPageControlRx() {
        viewModel.productImageURLs.asObservable()
            .map { $0.count }
            .bind(to: rx.numberOfPages)
            .disposed(by: disposeBag)
    }
    
    fileprivate func updatePageControlConstraints(forItemCount count: Int) {
        guard let pageControl = pageControl as? UIPageControl else { return }
        let width = pageControl.size(forNumberOfPages: count).width + CarouselUI.pageControlWidth
        pageControlWidth?.constant = width
        pageControlTopMargin?.constant = width / 2.0
    }

    fileprivate func setupUserInfoRx() {
        let productAndUserInfos = Observable.combineLatest(viewModel.productInfo.asObservable(),
                                                           viewModel.userInfo.asObservable(),
                                                           viewModel.ownerIsProfessional.asObservable(),
                                                           viewModel.ownerBadge.asObservable()) { ($0, $1, $2, $3) }

        productAndUserInfos.bind { [weak self]
            (productInfo: ListingVMProductInfo?,
            userInfo: ListingVMUserInfo?,
            isProfessional: Bool,
            userBadge: UserReputationBadge) in
            let shouldShowPaymentFrequency = self?.viewModel.shouldShowPaymentFrequency ?? false
            let featureFlags = self?.viewModel.featureFlags ?? FeatureFlags.sharedInstance
            self?.userView.setupWith(userAvatar: userInfo?.avatar,
                                     userName: userInfo?.name,
                                     productTitle: productInfo?.titleViewModel(featureFlags: featureFlags),
                                     productPrice: productInfo?.price,
                                     productPaymentFrequency: shouldShowPaymentFrequency ? productInfo?.paymentFrequency : nil,
                                     userId: userInfo?.userId,
                                     isProfessional: isProfessional,
                                     userBadge: userBadge)
        }.disposed(by: disposeBag)

        viewModel.userInfo.asObservable().bind { [weak self] userInfo in
            self?.fullScreenAvatarView.alpha = 0
            self?.fullScreenAvatarView.image = userInfo?.avatarPlaceholder()
            if let avatar = userInfo?.avatar {
                let _ = self?.imageDownloader.downloadImageWithURL(avatar) { [weak self] result, url in
                    guard let imageWithSource = result.value, url == self?.viewModel.userInfo.value?.avatar else { return }
                    self?.fullScreenAvatarView.image = imageWithSource.image
                }
            }
            }.disposed(by: disposeBag)
    }


    fileprivate func setupNavbarButtonsRx() {
        setNavigationBarRightButtons([])
        viewModel.navBarButtons.asObservable().subscribeNext { [weak self] navBarButtons in
            guard let strongSelf = self else { return }
            let takeUntilAction = strongSelf.viewModel.navBarButtons.asObservable().skip(1)
            if navBarButtons.count == 1 {
                let action = navBarButtons[0]
                switch action.interface {
                case .textImage:
                    let shareButton = CarouselUIHelper.buildShareButton(action.text, icon: action.image)
                    let rightItem = UIBarButtonItem(customView: shareButton)
                    rightItem.set(accessibility: action.accessibility)
                    rightItem.style = .plain
                    shareButton.rx.tap.takeUntil(takeUntilAction).bind{
                        action.action()
                        }.disposed(by: strongSelf.disposeBag)
                    let alpha = strongSelf.itemsAlpha.value
                    strongSelf.navigationItem.rightBarButtonItems = nil
                    strongSelf.navigationItem.rightBarButtonItem = rightItem
                    strongSelf.navigationItem.rightBarButtonItem?.customView?.alpha = alpha
                default:
                    strongSelf.setLetGoRightButtonWith(action, buttonTintColor: UIColor.white,
                                                       tapBlock: { tapEvent in
                                                        tapEvent.takeUntil(takeUntilAction).bind{
                                                            action.action()
                                                            }.disposed(by: strongSelf.disposeBag)
                    })
                }
            } else if navBarButtons.count > 1 {
                let alpha = strongSelf.itemsAlpha.value
                var buttons = [UIButton]()
                navBarButtons.forEach { navBarButton in
                    let button = UIButton(type: .system)
                    button.setImage(navBarButton.image, for: .normal)
                    button.rx.tap.takeUntil(takeUntilAction).bind { _ in
                        navBarButton.action()
                        }.disposed(by: strongSelf.disposeBag)
                    buttons.append(button)
                    button.alpha = alpha
                    button.set(accessibility: navBarButton.accessibility)
                }
                strongSelf.setNavigationBarRightButtons(buttons)
            }
            }.disposed(by: disposeBag)
    }

    private func setupBottomButtonsRx() {
        viewModel.actionButtons.asObservable().bind { [weak self] actionButtons in
            guard let strongSelf = self else { return }
            strongSelf.buttonBottomHeight.constant = actionButtons.isEmpty ? 0 : CarouselUI.buttonHeight
            strongSelf.buttonTopBottomConstraint.constant = actionButtons.isEmpty ? 0 : CarouselUI.itemsMargin
            strongSelf.buttonTopHeight.constant = actionButtons.count < 2 ? 0 : CarouselUI.buttonHeight
            strongSelf.userViewBottomConstraint?.constant = actionButtons.count < 2 ? 0 : -CarouselUI.itemsMargin
            guard !actionButtons.isEmpty else { return }
            let takeUntilAction = strongSelf.viewModel.actionButtons.asObservable().skip(1)
            guard let bottomAction = actionButtons.first else { return }
            strongSelf.buttonBottom.configureWith(uiAction: bottomAction)
            strongSelf.buttonBottom.rx.tap.takeUntil(takeUntilAction).bind {
                bottomAction.action()
                }.disposed(by: strongSelf.disposeBag)
            guard let topAction = actionButtons.last, actionButtons.count > 1 else { return }
            strongSelf.buttonTop.configureWith(uiAction: topAction)
            strongSelf.buttonTop.rx.tap.takeUntil(takeUntilAction).bind {
                topAction.action()
                }.disposed(by: strongSelf.disposeBag)
            }.disposed(by: disposeBag)

        let allowCalls = Observable.combineLatest(viewModel.ownerIsProfessional.asObservable(),
                                                  viewModel.ownerPhoneNumber.asObservable()) { ($0, $1) }
        allowCalls.asObservable().bind { [weak self] (isPro, phoneNum) in
            guard let strongSelf = self else { return }
            if phoneNum != nil, isPro && strongSelf.viewModel.deviceCanCall {
                strongSelf.buttonCall.isHidden = false
                strongSelf.buttonCallRightMarginToSuperviewConstraint.constant = Metrics.margin
                strongSelf.buttonBottomRightMarginToSuperviewConstraint.constant = 0

                let twoButtonsWidth: CGFloat = (strongSelf.view.width - (Metrics.margin*3))/2
                strongSelf.buttonBottomWidthConstraint.constant = twoButtonsWidth
                strongSelf.buttonCallWidthConstraint.constant = twoButtonsWidth
            } else {
                strongSelf.buttonCall.isHidden = true
                strongSelf.buttonCallRightMarginToSuperviewConstraint.constant = 0
                strongSelf.buttonBottomRightMarginToSuperviewConstraint.constant = Metrics.margin
                let oneButtonWidth: CGFloat = strongSelf.view.width - (Metrics.margin*2)
                strongSelf.buttonBottomWidthConstraint.constant = oneButtonWidth
                strongSelf.buttonCallWidthConstraint.constant = 0
            }
        }.disposed(by: disposeBag)
    }

    private func setupDirectChatElementsRx() {
        viewModel.directChatEnabled.asObservable().bind { [weak self] enabled in
            self?.buttonBottomBottomConstraint.constant = enabled ? CarouselUI.itemsMargin : 0
            self?.chatContainerHeight.constant = enabled ? CarouselUI.chatContainerMaxHeight : 0
            }.disposed(by: disposeBag)

        viewModel.directChatMessages.changesObservable.bind { [weak self] change in
            guard let strongSelf = self else { return }
            switch change {
            case .insert(_, let message):
                // if the message is already in the table we don't perform animations
                let chatMessageExists = strongSelf.viewModel.directChatMessages.value.filter({ $0.objectId == message.objectId }).count >= 1
                strongSelf.directChatTable.handleCollectionChange(change, animation: chatMessageExists ? .none : .top)
            default:
                strongSelf.directChatTable.handleCollectionChange(change, animation: .none)
            }
            }.disposed(by: disposeBag)
    }

    private func setupProductStatusLabelRx() {

        let statusAndFeatured = Observable.combineLatest(viewModel.status.asObservable(), viewModel.isFeatured.asObservable()) { ($0, $1) }
        statusAndFeatured.bind { [weak self] (status, isFeatured) in
            guard let strongSelf = self else { return }
            if isFeatured {
                strongSelf.productStatusView.backgroundColor = UIColor.white
                let featuredText = R.Strings.bumpUpProductDetailFeaturedLabel
                strongSelf.productStatusLabel.text = featuredText.capitalizedFirstLetterOnly
                strongSelf.productStatusLabel.textColor = UIColor.blackText
                strongSelf.productStatusImageView.isHidden = false
                strongSelf.productStatusImageViewLeftConstraint.constant = Metrics.shortMargin
                strongSelf.productStatusImageViewRightConstraint.constant = Metrics.shortMargin
                strongSelf.productStatusImageViewWidthConstraint.constant = Metrics.margin
                strongSelf.addTapRecognizerToStatusLabel()
            } else {
                strongSelf.productStatusView.backgroundColor = status.bgColor
                strongSelf.productStatusLabel.text = status.string
                strongSelf.productStatusLabel.textColor = status.labelColor
                strongSelf.productStatusImageView.isHidden = true
                strongSelf.productStatusImageViewLeftConstraint.constant = 0
                strongSelf.productStatusImageViewRightConstraint.constant = 0
                strongSelf.productStatusImageViewWidthConstraint.constant = 0
            }
            strongSelf.productStatusView.isHidden = strongSelf.productStatusLabel.text?.isEmpty ?? true
            }.disposed(by: disposeBag)
    }

    private func addTapRecognizerToStatusLabel() {
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(statusLabelTapped))
        productStatusView.addGestureRecognizer(tapRec)
    }

    @objc private dynamic func statusLabelTapped() {
        viewModel.statusLabelTapped()
    }

    private func setupFavoriteButtonRx() {
        viewModel.isFavorite.asObservable()
            .map { $0 ? R.Asset.IconsButtons.icFavoriteBigOn.image : R.Asset.IconsButtons.icFavoriteBigOff.image }
            .bind(to: favoriteButton.rx.image(for: .normal)).disposed(by: disposeBag)

        favoriteButton.rx.tap.bind { [weak self] in
            self?.viewModel.favoriteButtonPressed()
            }.disposed(by: disposeBag)
    }

    private func setupShareButtonRx() {
        viewModel.shareButtonState.asObservable().bind { [weak self] state in
            self?.shareButton.setState(state)
            }.disposed(by: disposeBag)

        shareButton.rx.tap.bind { [weak self] in
            self?.viewModel.shareButtonPressed()
            }.disposed(by: disposeBag)
    }

    private func setupBumpUpBannerRx() {
        bumpUpBanner.layoutIfNeeded()
        closeBumpUpBanner()
        viewModel.bumpUpBannerInfo.asObservable().bind{ [weak self] info in
            if let info = info {
                self?.showBumpUpBanner(bumpInfo: info)
            } else {
                self?.closeBumpUpBanner()
            }
            }.disposed(by: disposeBag)
    }

    private func setupUserInteractionRxBindings() {
        cellAnimating.asObservable().map { !$0 } .bind(to: view.rx.isUserInteractionEnabled).disposed(by: disposeBag)
    }

    fileprivate func resetMoreInfoState() {
        moreInfoView.frame = view.bounds
        if #available(iOS 11.0, *) {
            moreInfoView.height = view.height + view.safeAreaInsets.top
            moreInfoView.updateBottomAreaMargin(with: view.safeAreaInsets.top)
        } else {
            moreInfoView.height = view.height + CarouselUI.moreInfoExtraHeight
            moreInfoView.updateBottomAreaMargin(with: CarouselUI.moreInfoExtraHeight)
        }
        moreInfoView.frame.origin.y = -view.bounds.height
        moreInfoState.value = .hidden
    }

    private func finishedTransition() {
        showStatusBar()
    }

}

extension ListingCarouselViewController: UserViewDelegate {
    func userViewAvatarPressed(_ userView: UserView) {
        viewModel.userAvatarPressed()
    }

    func userViewTextInfoContainerPressed(_ userView: UserView) {
        showMoreInfo()
    }

    func userViewAvatarLongPressStarted(_ userView: UserView) {
        view.bringSubview(toFront: fullScreenAvatarView)
        fullScreenAvatarLeft?.constant = userView.frame.left + userView.userAvatarImageView.frame.left
        fullScreenAvatarTop?.constant = userView.frame.top + userView.userAvatarImageView.frame.top
        fullScreenAvatarWidth?.constant = userView.userAvatarImageView.frame.size.width
        fullScreenAvatarHeight?.constant = userView.userAvatarImageView.frame.size.height
        view.layoutIfNeeded()

        let viewSide = min(view.frame.width, view.frame.height)
        fullScreenAvatarLeft?.constant = view.frame.centerX - viewSide/2
        fullScreenAvatarTop?.constant = view.frame.centerY - viewSide/2
        fullScreenAvatarWidth?.constant = viewSide
        fullScreenAvatarHeight?.constant = viewSide
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.updateNavigationBarAlpha(0)
            self?.moreInfoTooltip?.alpha = 0
            self?.fullScreenAvatarEffectView.alpha = 1
            self?.fullScreenAvatarView.alpha = 1
            self?.view.layoutIfNeeded()
        })
    }

    func userViewAvatarLongPressEnded(_ userView: UserView) {
        fullScreenAvatarLeft?.constant = userView.frame.left + userView.userAvatarImageView.frame.left
        fullScreenAvatarTop?.constant = userView.frame.top + userView.userAvatarImageView.frame.top
        fullScreenAvatarWidth?.constant = userView.userAvatarImageView.frame.size.width
        fullScreenAvatarHeight?.constant = userView.userAvatarImageView.frame.size.height
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.updateNavigationBarAlpha(1)
            self?.moreInfoTooltip?.alpha = 1
            self?.fullScreenAvatarEffectView.alpha = 0
            self?.fullScreenAvatarView.alpha = 0
            self?.view.layoutIfNeeded()
        })
    }
}


// MARK: > ListingCarousel Cell Delegate

extension ListingCarouselViewController: ListingCarouselCellDelegate {

    static let animatedLayoutRubberBandOffset: CGFloat = 100
    static let defaultRubberBandOffset: CGFloat = 50

    func didTapOnCarouselCell(_ cell: UICollectionViewCell, tapSide: ListingCarouselTapSide?) {
        guard !chatContainer.isFirstResponder else {
            chatContainer.resignFirstResponder()
            return
        }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        cellAnimating.value = true
        let actualTapSide = tapSide ?? .right
        switch actualTapSide {
        case .left:
            var contentOffset = collectionContentOffset.value
            contentOffset.x -= cell.width
            if contentOffset.x >= 0 {
                collectionView.setContentOffset(contentOffset, animated: true)
            } else {
                collectionView.showRubberBandEffect(.left,
                                                    offset: ListingCarouselViewController.defaultRubberBandOffset)

            }
        case .right:
            let newIndexRow = indexPath.row + 1
            if newIndexRow < collectionView.numberOfItems(inSection: 0) {
                pendingMovement = .tap
                let nextIndexPath = IndexPath(item: newIndexRow, section: 0)
                collectionView.scrollToItem(at: nextIndexPath, at: .right, animated: true)
            } else {
                collectionView.showRubberBandEffect(.right,
                                                    offset: ListingCarouselViewController.defaultRubberBandOffset)
            }
        }
    }

    func isZooming(_ zooming: Bool) {
        cellZooming.value = zooming
    }

    func didScrollToPage(_ page: Int) {
        pageControl.setCurrentPage(to: page, animated: true)
        shouldShowProgressView = viewModel.itemIsPlayable(at: page)
    }

    func didChangeVideoProgress(progress: Float, atIndex index: Int) {
        guard index == viewModel.currentIndex else { return }
        progressView.progress = progress
    }

    func didChangeVideoStatus(status: VideoPreview.Status, pageAtIndex index: Int) {
        guard index == viewModel.currentIndex else { return }
        progressView.isHidden = status != .readyToPlay
    }

    func didPullFromCellWith(_ offset: CGFloat, bottomLimit: CGFloat) {
        dragMoreInfoView(offset: offset, bottomLimit: bottomLimit)
    }

    func didEndDraggingCell() {
        updateMoreInfoFrame()
    }

    func canScrollToNextPage() -> Bool {
        return moreInfoState.value == .hidden
    }

}


// MARK: > More Info

extension ListingCarouselViewController {

    @objc func didTapMoreInfo() {
        chatContainer.resignFirstResponder()
    }

    func setupMoreInfoDragging() {
        let button = moreInfoView.dragView
        self.navigationController?.navigationBar.ignoreTouchesFor(button)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragMoreInfoButton))
        button.addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dragViewTapped))
        button.addGestureRecognizer(tap)
        moreInfoView.delegate = self
    }

    @objc func dragMoreInfoButton(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: view)

        if point.y >= CarouselUI.moreInfoExtraHeight { // start dragging when point is below the navbar
            moreInfoView.frame.bottom = point.y
        }

        switch pan.state {
        case .ended:
            if point.y > CarouselUI.moreInfoDragMargin {
                showMoreInfo()
            } else {
                hideMoreInfo()
            }
        default:
            break
        }
    }

    @objc func dragViewTapped(_ tap: UITapGestureRecognizer) {
        showMoreInfo()
    }

    @IBAction func showMoreInfo() {
        guard moreInfoState.value == .hidden || moreInfoState.value == .moving else { return }

        moreInfoView.viewWillShow()
        chatContainer.resignFirstResponder()
        moreInfoState.value = .shown

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: [],
                       animations: { [weak self] in
                        self?.moreInfoView.frame.origin.y = 0
            }, completion: nil)
    }

    func hideMoreInfo() {
        guard moreInfoState.value == .shown || moreInfoState.value == .moving else { return }

        moreInfoState.value = .hidden
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: [],
                       animations: { [weak self] in
                        guard let `self` = self else { return }
                        self.moreInfoView.frame.origin.y = -self.view.bounds.height
            }, completion: { [weak self] _ in
                self?.moreInfoView.dismissed()
        })
    }

    func compressMap() {
        guard moreInfoView.mapExpanded else { return }
        moreInfoView.compressMap()
    }

    func addIgnoreTouchesForMoreInfo() {
        self.navigationController?.navigationBar.ignoreTouchesFor(moreInfoView.dragView)
    }

    func removeIgnoreTouchesForMoreInfo() {
        self.navigationController?.navigationBar.endIgnoreTouchesFor(moreInfoView.dragView)
    }

    fileprivate func dragMoreInfoView(offset: CGFloat, bottomLimit: CGFloat) {
        guard moreInfoState.value != .shown && !cellZooming.value else { return }
        if moreInfoView.frame.origin.y - offset > -view.frame.height {
            moreInfoState.value = .moving
            moreInfoView.frame.origin.y = moreInfoView.frame.origin.y-offset
        } else {
            moreInfoState.value = .hidden
            moreInfoView.frame.origin.y = -view.frame.height
        }

        let bottomOverScroll = max(offset-bottomLimit, 0)
        bottomItemsMargin = CarouselUI.itemsMargin + bottomOverScroll
    }

    fileprivate func updateMoreInfoFrame() {
        if moreInfoView.frame.bottom > CarouselUI.moreInfoDragMargin*2 {
            showMoreInfo()
        } else {
            hideMoreInfo()
        }
    }
}


// MARK: More Info Delegate

extension ListingCarouselViewController: ProductCarouselMoreInfoDelegate {

    func didEndScrolling(_ topOverScroll: CGFloat, bottomOverScroll: CGFloat) {
        if topOverScroll > CarouselUI.moreInfoDragMargin || bottomOverScroll > CarouselUI.moreInfoDragMargin {
            hideMoreInfo()
        }
    }

    func viewControllerToShowShareOptions() -> UIViewController {
        return self
    }

    func request(fullScreen: Bool) {
        if fullScreen {
            chatContainer.resignFirstResponder()
        }
        // If more info requests full screen all items except it should be removed/hidden
        UIView.animate(withDuration: LGUIKitConstants.defaultAnimationTime) { [weak self] in
            self?.itemsAlpha.value = fullScreen ? 0 : 1
            self?.navigationItem.rightBarButtonItem?.customView?.alpha = fullScreen ? 0 : 1
            self?.navigationItem.rightBarButtonItems?.forEach {
                $0.customView?.alpha = fullScreen ? 0 : 1
            }
        }
    }

    func rootViewControllerForDFPBanner() -> UIViewController {
        return self
    }
}


// MARK: > ToolTip

extension ListingCarouselViewController {

    fileprivate func setupMoreInfoTooltip() {
        guard viewModel.shouldShowMoreInfoTooltip else { return }
        let tooltipText = CarouselUIHelper.buildMoreInfoTooltipText()
        let moreInfoTooltip = Tooltip(targetView: moreInfoView, superView: view, title: tooltipText,
                                      style: .blue(closeEnabled: false), peakOnTop: true,
                                      actionBlock: { [weak self] in self?.showMoreInfo() }, closeBlock: nil)
        view.addSubview(moreInfoTooltip)
        setupExternalConstraintsForTooltip(moreInfoTooltip, targetView: moreInfoView.dragView, containerView: view)
        self.moreInfoTooltip = moreInfoTooltip
    }

    fileprivate func removeMoreInfoTooltip() {
        moreInfoTooltip?.removeFromSuperview()
        moreInfoTooltip = nil
    }
}


// MARK: > CollectionView delegates

extension ListingCarouselViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private static let listingCarouselCellCount = 3

    func registerListingCarouselCells() {
        for i in 0..<ListingCarouselViewController.listingCarouselCellCount {
            collectionView.register(ListingCarouselCell.self,
                                    forCellWithReuseIdentifier: cellIdentifierForIndex(i))
        }
    }

    func cellIdentifierForIndex(_ index: Int) -> String {
        let extra = String(index % ListingCarouselViewController.listingCarouselCellCount)
        return ListingCarouselCell.identifier+extra
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard didSetupAfterLayout else { return 0 }
        return viewModel.objectCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifierForIndex(indexPath.row),
                                                          for: indexPath)
            guard let carouselCell = cell as? ListingCarouselCell else { return UICollectionViewCell() }
            guard let listingCellModel = viewModel.listingCellModelAt(index: indexPath.row) else { return carouselCell }
            carouselCell.configureCellWith(cellModel: listingCellModel, placeholderImage: viewModel.thumbnailAtIndex(indexPath.row),
                                           indexPath: indexPath, imageDownloader: carouselImageDownloader,
                                           imageScrollDirection: viewModel.imageScrollDirection)
            carouselCell.delegate = self
            carouselCell.tag = indexPath.row
            carouselCell.position = indexPath.row
            
            return carouselCell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideMoreInfo()
        collectionContentOffset.value = scrollView.contentOffset

        if viewModel.imageScrollDirection == .horizontal {
            dragMoreInfoView(offset: scrollView.contentOffset.y, bottomLimit: bottomScrollLimit)
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        cellAnimating.value = false
    }
}


// MARK: > Direct messages and stickers

extension ListingCarouselViewController: UITableViewDataSource, UITableViewDelegate {
    func setupDirectMessages() {
        ChatCellDrawerFactory.registerCells(directChatTable)
        directChatTable.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        directChatTable.rowHeight = UITableViewAutomaticDimension
        directChatTable.estimatedRowHeight = 140
        directChatTable.isCellHiddenBlock = { return $0.contentView.isHidden }
        directChatTable.didSelectRowAtIndexPath = {  [weak self] _ in self?.viewModel.directMessagesItemPressed() }

        chatContainer.setup(with: viewModel)

        keyboardChanges.bind { [weak self] change in
            guard let strongSelf = self else { return }
            let viewHeight = strongSelf.view.height
            self?.contentBottomMargin = viewHeight - change.origin
            UIView.animate(withDuration: Double(change.animationTime)) {
                strongSelf.view.layoutIfNeeded()
            }
            }.disposed(by: disposeBag)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.directChatMessages.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messages = viewModel.directChatMessages.value
        guard 0..<messages.count ~= indexPath.row else { return UITableViewCell() }
        let message = messages[indexPath.row]
        let drawer = ChatCellDrawerFactory.drawerForMessage(message,
                                                            autoHide: true,
                                                            disclosure: true,
                                                            meetingsEnabled: viewModel.meetingsEnabled)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)

        drawer.draw(cell, message: message, bubbleColor: nil)
        cell.transform = tableView.transform

        return cell
    }
}


// MARK: > Bump Up bubble

extension ListingCarouselViewController {
    func showBumpUpBanner(bumpInfo: BumpUpInfo){
        guard bannerContainer.isHidden else {
            // banner is already visible, but info changes
            if bumpUpBanner.type != bumpInfo.type {
                bumpUpBanner.updateInfo(info: bumpInfo)
                updateBannerHeightFor(type: bumpInfo.type)
            }
            return
        }

        viewModel.bumpUpBannerShown(bumpInfo: bumpInfo)
        bannerContainer.bringSubview(toFront: bumpUpBanner)
        bannerContainer.isHidden = false
        bumpUpBanner.updateInfo(info: bumpInfo)

        updateBannerHeightFor(type: bumpInfo.type)
    }

    func closeBumpUpBanner() {
        guard !bannerContainer.isHidden else { return }
        bannerBottom = -bannerHeight
        bumpUpBanner.stopCountdown()
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            self?.bannerContainer.isHidden = true
        })
    }

    private func updateBannerHeightFor(type: BumpUpType) {
        let bannerTotalHeight: CGFloat
        switch type {
        case .boost(let boostBannerVisible):
            bannerTotalHeight = boostBannerVisible ? CarouselUI.bannerHeight*2 : CarouselUI.bannerHeight
        case .free, .hidden, .priced, .restore, .loading:
            bannerTotalHeight = CarouselUI.bannerHeight
        }

        delay(0.1) { [weak self] in
            guard let bannerHidden = self?.bannerContainer.isHidden, !bannerHidden else { return }
            self?.bannerBottom = 0
            self?.bannerHeight = bannerTotalHeight
            UIView.animate(withDuration: 0.3, animations: {
                self?.view.layoutIfNeeded()
            })
        }
    }
}

extension ListingCarouselViewController: BumpUpBannerBoostDelegate {
    func bumpUpTimerReachedZero() {
        closeBumpUpBanner()
        viewModel.bumpUpBannerBoostTimerReachedZero()
    }

    func updateBoostBannerFor(type: BumpUpType) {
        updateBannerHeightFor(type: type)
    }
}


// MARK: > ListingCarouselViewModelDelegate

extension ListingCarouselViewController: ListingCarouselViewModelDelegate {

    func vmRemoveMoreInfoTooltip() {
        removeMoreInfoTooltip()
    }

    func vmShowOnboarding() {
        guard let navigationCtrlView = navigationController?.view ?? view else { return }
        let onboardingVM = ListingDetailOnboardingViewModel()
        onboardingVM.delegate = self
        productOnboardingView = ListingDetailOnboardingView(viewModel: onboardingVM)

        guard let onboarding = productOnboardingView else { return }
        navigationCtrlView.addSubview(onboarding)
        onboarding.setupUI()
        onboarding.frame = navigationCtrlView.frame
        onboarding.layoutIfNeeded()
    }

    func vmShowCarouselOptions(_ cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: navigationItem.rightBarButtonItems?.first)
    }

    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        return (self, navigationItem.rightBarButtonItems?.first)
    }

    func vmResetBumpUpBannerCountdown() {
        bumpUpBanner.resetCountdown()
    }

    // Loadings and alerts overrides to remove keyboard before showing

    override func vmShowLoading(_ loadingMessage: String?) {
        chatContainer.resignFirstResponder()
        super.vmShowLoading(loadingMessage)
    }

    override func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        chatContainer.resignFirstResponder()
        super.vmShowAutoFadingMessage(message, completion: completion)
    }
}


// MARK: - ListingDetailOnboardingViewDelegate

extension ListingCarouselViewController: ListingDetailOnboardingViewDelegate {
    func listingDetailOnboardingDidAppear() {
        // nav bar behaves weird when is hidden in mainproducts list and the onboarding is shown
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func listingDetailOnboardingDidDisappear() {
        // nav bar shown again, but under the onboarding
        navigationController?.setNavigationBarHidden(false, animated: false)
        productOnboardingView = nil
    }
}

extension ListingCarouselViewController {
    // MARK: UITabBarController / TabBar animations & position

    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .overFullScreen
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}


// MARK: - Accessibility ids

fileprivate extension ListingCarouselViewController {
    func setAccessibilityIds() {
        collectionView.set(accessibilityId: .listingCarouselCollectionView)
        buttonBottom.set(accessibilityId: .listingCarouselButtonBottom)
        buttonTop.set(accessibilityId: .listingCarouselButtonTop)
        favoriteButton.set(accessibilityId: .listingCarouselFavoriteButton)
        moreInfoView.set(accessibilityId: .listingCarouselMoreInfoView)
        productStatusLabel.set(accessibilityId: .listingCarouselListingStatusLabel)
        directChatTable.set(accessibilityId: .listingCarouselDirectChatTable)
        fullScreenAvatarView.set(accessibilityId: .listingCarouselFullScreenAvatarView)
        pageControl.set(accessibilityId: .listingCarouselPageControl)
        userView.set(accessibilityId: .listingCarouselUserView)
        productStatusView.set(accessibilityId: .listingCarouselStatusView)
        directChatTable.accessibilityInspectionEnabled = false
        progressView.set(accessibilityId: .listingCarouselVideoProgressView)
    }
}

// MARK: - GADIntertitialDelegate

extension ListingCarouselViewController: GADInterstitialDelegate {
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        setupInterstitial()
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        viewModel.interstitialAdShown(typePage: EventParameterTypePage.nextItem)
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        viewModel.interstitialAdTapped(typePage: EventParameterTypePage.nextItem)
    }
    
}


extension Reactive where Base: ListingCarouselViewController {
    
    var currentPage: Binder<Int> {
        return Binder(self.base) { view, currentPage in
            view.pageControl.setCurrentPage(to: currentPage, animated: true)
        }
    }
    
    var numberOfPages: Binder<Int> {
        return Binder(self.base) { view, numberOfPages in
            view.pageControl.setup(withNumberOfPages: numberOfPages)
            view.pageControl.setCurrentPage(to: 0, animated: false)
            view.updatePageControlConstraints(forItemCount: numberOfPages)
        }
    }
}
