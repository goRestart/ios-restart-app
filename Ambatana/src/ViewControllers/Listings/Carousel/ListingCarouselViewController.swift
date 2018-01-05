//
//  ListingCarouselViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class ListingCarouselViewController: KeyboardViewController, AnimatableTransition {

    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonBottom: UIButton!
    @IBOutlet weak var buttonBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTop: UIButton!
    @IBOutlet weak var buttonTopHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonTopBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatContainer: UIView!
    @IBOutlet weak var chatContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var chatContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var gradientShadowView: UIView!
    @IBOutlet weak var gradientShadowBottomView: UIView!

    @IBOutlet weak var favoriteButtonTopAligment: NSLayoutConstraint!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareButtonTopAlignment: NSLayoutConstraint!
    
    @IBOutlet weak var productStatusView: UIView!
    @IBOutlet weak var productStatusLabel: UILabel!
    @IBOutlet weak var productStatusImageView: UIImageView!
    @IBOutlet weak var productStatusImageViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var productStatusImageViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var productStatusImageViewWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var directChatTable: CustomTouchesTableView!

    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var bannerContainerBottomConstraint: NSLayoutConstraint!

    fileprivate let userView: UserView
    fileprivate let fullScreenAvatarEffectView: UIVisualEffectView
    fileprivate let fullScreenAvatarView: UIImageView
    fileprivate var fullScreenAvatarWidth: NSLayoutConstraint?
    fileprivate var fullScreenAvatarHeight: NSLayoutConstraint?
    fileprivate var fullScreenAvatarTop: NSLayoutConstraint?
    fileprivate var fullScreenAvatarLeft: NSLayoutConstraint?
    fileprivate let viewModel: ListingCarouselViewModel
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    fileprivate var userViewBottomConstraint: NSLayoutConstraint?
    fileprivate var userViewRightConstraint: NSLayoutConstraint?

    fileprivate let mainViewBlurEffectView: UIVisualEffectView

    fileprivate var userViewRightMargin: CGFloat = CarouselUI.itemsMargin {
        didSet {
            userViewRightConstraint?.constant = -userViewRightMargin
        }
    }

    fileprivate var bottomItemsMargin: CGFloat = CarouselUI.itemsMargin {
        didSet {
            chatContainerBottomConstraint?.constant = bottomItemsMargin
        }
    }
    fileprivate var bannerBottom: CGFloat = -CarouselUI.bannerHeight {
        didSet {
            bannerContainerBottomConstraint?.constant = contentBottomMargin + bannerBottom
        }
    }
    fileprivate var contentBottomMargin: CGFloat = 0 {
        didSet {
            bannerContainerBottomConstraint?.constant = contentBottomMargin + bannerBottom
        }
    }

    fileprivate let pageControl: UIPageControl
    fileprivate var moreInfoTooltip: Tooltip?

    fileprivate let collectionContentOffset = Variable<CGPoint>(CGPoint.zero)
    fileprivate let itemsAlpha = Variable<CGFloat>(1)
    fileprivate let cellZooming = Variable<Bool>(false)
    fileprivate let cellAnimating = Variable<Bool>(false)

    fileprivate var activeDisposeBag = DisposeBag()
    private var productInfoConstraintOffset: CGFloat = 0

    fileprivate var productOnboardingView: ListingDetailOnboardingView?
    fileprivate var didSetupAfterLayout = false

    fileprivate let moreInfoView: ListingCarouselMoreInfoView
    fileprivate let moreInfoAlpha = Variable<CGFloat>(1)
    fileprivate let moreInfoState = Variable<MoreInfoState>(.hidden)

    fileprivate let chatTextView = ChatTextView()
    fileprivate let directAnswersView: DirectAnswersHorizontalView
    fileprivate var directAnswersBottom = NSLayoutConstraint()

    fileprivate var bumpUpBanner = BumpUpBanner()
    fileprivate var bumpUpBannerIsVisible: Bool = false

    let animator: PushAnimator?
    var pendingMovement: CarouselMovement?

    fileprivate let carouselImageDownloader: ImageDownloaderType
    fileprivate let imageDownloader: ImageDownloaderType

    fileprivate var bottomScrollLimit: CGFloat {
        return max(0, collectionView.contentSize.height - collectionView.height + collectionView.contentInset.bottom)
    }


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
        self.pageControl = UIPageControl(frame: CGRect.zero)
        self.imageDownloader = imageDownloader
        self.carouselImageDownloader = carouselImageDownloader
        self.directAnswersView = DirectAnswersHorizontalView(answers: [], sideMargin: CarouselUI.itemsMargin)
        self.moreInfoView = ListingCarouselMoreInfoView.moreInfoView()
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
        setAccessibilityIds()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if moreInfoState.value == .shown {
            moreInfoView.viewWillShow()
        }
    }

    override func viewDidFirstAppear(_ animated: Bool) {
        super.viewDidFirstAppear(animated)

        switch viewModel.actionOnFirstAppear {
        case .showKeyboard:
            chatTextView.becomeFirstResponder()
        case .showShareSheet:
            viewModel.shareButtonPressed()
        case let .triggerBumpUp(purchaseableProduct, paymentItemId, paymentProviderItemId, bumpUpType, triggerBumpUpSource):
            viewModel.showBumpUpView(purchaseableProduct: purchaseableProduct,
                                     paymentItemId: paymentItemId,
                                     paymentProviderItemId: paymentProviderItemId,
                                     bumpUpType: bumpUpType, bumpUpSource: triggerBumpUpSource)
        case .triggerMarkAsSold:
            viewModel.currentListingViewModel?.markAsSold()
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
            if animator.toViewValidatedFrame || !animator.active {
                setupAfterLayout(backgroundImage: animator.fromViewSnapshot, activeAnimator: animator.active)
            }
        } else {
            setupAfterLayout(backgroundImage: nil, activeAnimator: false)
        }
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
        mainViewBlurEffectView.translatesAutoresizingMaskIntoConstraints = false
        imageBackground.addSubview(mainViewBlurEffectView)
        view.addSubview(pageControl)
        fullScreenAvatarEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullScreenAvatarEffectView)
        userView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userView)
        fullScreenAvatarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullScreenAvatarView)
    }

    func setupUI() {
        addSubviews()
        if !isSafeAreaAvailable {
            favoriteButtonTopAligment.constant = 55
            shareButtonTopAlignment.constant = 70
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

        CarouselUIHelper.setupPageControl(pageControl, topBarHeight: topBarHeight)

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

        productStatusView.rounded = true
        productStatusLabel.textColor = UIColor.soldColor
        productStatusLabel.font = UIFont.productStatusSoldFont

        CarouselUIHelper.setupShareButton(shareButton,
                                          text: LGLocalizedString.productShareNavbarButton,
                                          icon: UIImage(named:"ic_share"))

        mainResponder = chatTextView
        setupDirectMessages()
        setupBumpUpBanner()
        
        moreInfoView.updateDragViewVerticalConstraint(statusBarHeight: statusBarHeight)
    }

    func setupBumpUpBanner() {
        bannerContainer.addSubview(bumpUpBanner)
        bumpUpBanner.translatesAutoresizingMaskIntoConstraints = false
        bumpUpBanner.layout(with: bannerContainer).fill()
        bannerContainer.isHidden = true
    }

    private func setupMoreInfo() {
        view.addSubview(moreInfoView)
        moreInfoAlpha.asObservable().bind(to: moreInfoView.rx.alpha).disposed(by: disposeBag)
        moreInfoAlpha.asObservable().bind(to: moreInfoView.dragView.rx.alpha).disposed(by: disposeBag)

        view.bringSubview(toFront: buttonBottom)
        view.bringSubview(toFront: chatContainer)
        view.bringSubview(toFront: bannerContainer)
        view.bringSubview(toFront: fullScreenAvatarEffectView)
        view.bringSubview(toFront: fullScreenAvatarView)
        view.bringSubview(toFront: directChatTable)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMoreInfo))
        moreInfoView.addGestureRecognizer(tapGesture)
    }

    private func setupNavigationBar() {
        let backIconImage = UIImage(named: "ic_close_carousel")
        let backButton = UIBarButtonItem(image: backIconImage, style: UIBarButtonItemStyle.plain,
                                         target: self, action: #selector(backButtonClose))
        self.navigationItem.leftBarButtonItem = backButton
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
            UIApplication.shared.setStatusBarHidden(zooming, with: .fade)
            UIView.animate(withDuration: 0.3) {
                self?.itemsAlpha.value = zooming ? 0 : 1
                self?.moreInfoAlpha.value = zooming ? 0 : 1
                self?.updateNavigationBarAlpha(zooming ? 0 : 1)
            }
            }.disposed(by: disposeBag)
    }

    private func setupAlphaRxBindings() {
        itemsAlpha.asObservable().bind(to: buttonBottom.rx.alpha).disposed(by: disposeBag)
        itemsAlpha.asObservable().bind(to: buttonTop.rx.alpha).disposed(by: disposeBag)
        itemsAlpha.asObservable().bind(to: userView.rx.alpha).disposed(by: disposeBag)

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
                if movement == .tap {
                    self?.finishedTransition()
                }
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
        let visibleCells = collectionView.visibleCells.flatMap { $0 as? ListingCarouselCell }
        visibleCells.filter {
            guard let index = collectionView.indexPath(for: $0) else { return false }
            return index.row != viewModel.currentIndex
            }.forEach { $0.returnToFirstImage() }
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
        viewModel.productImageURLs.asObservable().bind { [weak self] images in
            guard let pageControl = self?.pageControl else { return }
            pageControl.currentPage = 0
            pageControl.numberOfPages = images.count
            pageControl.frame.size = CGSize(width: CarouselUI.pageControlWidth, height:
                pageControl.size(forNumberOfPages: images.count).width + CarouselUI.pageControlWidth)
        }.disposed(by: disposeBag)
    }

    fileprivate func setupUserInfoRx() {
        let productAndUserInfos = Observable.combineLatest(viewModel.productInfo.asObservable(), viewModel.userInfo.asObservable()) { ($0, $1) }
        productAndUserInfos.bind { [weak self] (productInfo, userInfo) in
            self?.userView.setupWith(userAvatar: userInfo?.avatar,
                                     userName: userInfo?.name,
                                     productTitle: productInfo?.title,
                                     productPrice: productInfo?.price,
                                     userId: userInfo?.userId)
            }.disposed(by: disposeBag)

        viewModel.userInfo.asObservable().bind { [weak self] userInfo in
            self?.fullScreenAvatarView.alpha = 0
            self?.fullScreenAvatarView.image = userInfo?.avatarPlaceholder
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
    }

    private func setupDirectChatElementsRx() {
        viewModel.directChatPlaceholder.asObservable().bind { [weak self] placeholder in
            self?.chatTextView.placeholder = placeholder
            }.disposed(by: disposeBag)
        if let productVM = viewModel.currentListingViewModel, !productVM.areQuickAnswersDynamic {
            chatTextView.setInitialText(LGLocalizedString.chatExpressTextFieldText)
        }

        viewModel.directChatEnabled.asObservable().bind { [weak self] enabled in
            self?.buttonBottomBottomConstraint.constant = enabled ? CarouselUI.itemsMargin : 0
            self?.chatContainerHeight.constant = enabled ? CarouselUI.chatContainerMaxHeight : 0
            }.disposed(by: disposeBag)

        viewModel.quickAnswers.asObservable().bind { [weak self] quickAnswers in
            let isDynamic = self?.viewModel.currentListingViewModel?.areQuickAnswersDynamic ?? false
            self?.directAnswersView.update(answers: quickAnswers, isDynamic: isDynamic)
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

        chatTextView.rx.send.bind { [weak self] textToSend in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.send(directMessage: textToSend, isDefaultText: strongSelf.chatTextView.isInitialText)
            strongSelf.chatTextView.clear()
            }.disposed(by: disposeBag)
    }

    private func setupProductStatusLabelRx() {

        let statusAndFeatured = Observable.combineLatest(viewModel.status.asObservable(), viewModel.isFeatured.asObservable()) { ($0, $1) }
        statusAndFeatured.bind { [weak self] (status, isFeatured) in
            guard let strongSelf = self else { return }
            if isFeatured {
                strongSelf.productStatusView.backgroundColor = UIColor.white
                let featuredText = LGLocalizedString.bumpUpProductDetailFeaturedLabel
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
            .map { UIImage(named: $0 ? "ic_favorite_big_on" : "ic_favorite_big_off") }
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
        moreInfoView.height = view.height + CarouselUI.moreInfoExtraHeight
        moreInfoView.frame.origin.y = -view.bounds.height
        moreInfoState.value = .hidden
    }

    fileprivate func finishedTransition() {
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
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
        guard !chatTextView.isFirstResponder else {
            chatTextView.resignFirstResponder()
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
        pageControl.currentPage = page
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
        chatTextView.resignFirstResponder()
    }

    func setupMoreInfoDragging() {
        guard let button = moreInfoView.dragView else { return }
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
        chatTextView.resignFirstResponder()
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
        guard let button = moreInfoView.dragView else { return }
        self.navigationController?.navigationBar.ignoreTouchesFor(button)
    }

    func removeIgnoreTouchesForMoreInfo() {
        guard let button = moreInfoView.dragView else { return }
        self.navigationController?.navigationBar.endIgnoreTouchesFor(button)
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
            chatTextView.resignFirstResponder()
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

extension ListingCarouselViewController: UITableViewDataSource, UITableViewDelegate, DirectAnswersHorizontalViewDelegate {
    func setupDirectMessages() {
        ChatCellDrawerFactory.registerCells(directChatTable)
        directChatTable.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        directChatTable.rowHeight = UITableViewAutomaticDimension
        directChatTable.estimatedRowHeight = 140
        directChatTable.isCellHiddenBlock = { return $0.contentView.isHidden }
        directChatTable.didSelectRowAtIndexPath = {  [weak self] _ in self?.viewModel.directMessagesItemPressed() }

        directAnswersView.delegate = self
        directAnswersView.style = .light
        directAnswersView.translatesAutoresizingMaskIntoConstraints = false
        chatContainer.addSubview(directAnswersView)
        directAnswersView.layout(with: chatContainer).leading().trailing().top()

        chatTextView.translatesAutoresizingMaskIntoConstraints = false
        chatContainer.addSubview(chatTextView)
        chatTextView.layout(with: chatContainer).leading(by: CarouselUI.itemsMargin).trailing(by: -CarouselUI.itemsMargin).bottom()
        let directAnswersBottom: CGFloat = CarouselUI.itemsMargin
        chatTextView.layout(with: directAnswersView).top(to: .bottom, by: directAnswersBottom,
                                                         constraintBlock: { [weak self] in self?.directAnswersBottom = $0 })

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
                                                            showClock: viewModel.featureFlags.showClockInDirectAnswer == .active)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)

        drawer.draw(cell, message: message)
        cell.transform = tableView.transform

        return cell
    }

    func directAnswersHorizontalViewDidSelect(answer: QuickAnswer, index: Int) {
        if let productVM = viewModel.currentListingViewModel, productVM.showKeyboardWhenQuickAnswer {
            chatTextView.setText(answer.text)
        } else {
            viewModel.send(quickAnswer: answer)
        }

        if let productVM = viewModel.currentListingViewModel, productVM.areQuickAnswersDynamic {
            viewModel.moveQuickAnswerToTheEnd(index)
        }
    }

}


// MARK: > Bump Up bubble

extension ListingCarouselViewController {
    func showBumpUpBanner(bumpInfo: BumpUpInfo){
        guard !bumpUpBannerIsVisible else {
            // banner is already visible, but info changes
            if bumpUpBanner.type != bumpInfo.type {
                bumpUpBanner.updateInfo(info: bumpInfo)
            }
            return
        }

        viewModel.bumpUpBannerShown(type: bumpInfo.type)
        bannerContainer.bringSubview(toFront: bumpUpBanner)
        bumpUpBannerIsVisible = true
        bannerContainer.isHidden = false
        bumpUpBanner.updateInfo(info: bumpInfo)
        delay(0.1) { [weak self] in
            guard let visible = self?.bumpUpBannerIsVisible, visible else { return }
            self?.bannerBottom = 0
            UIView.animate(withDuration: 0.3, animations: {
                self?.view.layoutIfNeeded()
            })
        }
    }

    func closeBumpUpBanner() {
        guard bumpUpBannerIsVisible else { return }
        bumpUpBannerIsVisible = false
        bannerBottom = -CarouselUI.bannerHeight
        bumpUpBanner.stopCountdown()
        bannerContainer.isHidden = true
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
        chatTextView.resignFirstResponder()
        super.vmShowLoading(loadingMessage)
    }

    override func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        chatTextView.resignFirstResponder()
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


// MARK: - Accessibility ids

fileprivate extension ListingCarouselViewController {
    func setAccessibilityIds() {
        collectionView.accessibilityId = .listingCarouselCollectionView
        buttonBottom.accessibilityId = .listingCarouselButtonBottom
        buttonTop.accessibilityId = .listingCarouselButtonTop
        favoriteButton.accessibilityId = .listingCarouselFavoriteButton
        moreInfoView.accessibilityId = .listingCarouselMoreInfoView
        productStatusLabel.accessibilityId = .listingCarouselListingStatusLabel
        directChatTable.accessibilityId = .listingCarouselDirectChatTable
        fullScreenAvatarView.accessibilityId = .listingCarouselFullScreenAvatarView
        pageControl.accessibilityId = .listingCarouselPageControl
        userView.accessibilityId = .listingCarouselUserView
        chatTextView.accessibilityId = .listingCarouselChatTextView
        productStatusView.accessibilityId = .listingCarouselStatusView
    }
}

