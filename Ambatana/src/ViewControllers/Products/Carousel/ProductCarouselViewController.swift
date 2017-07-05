//
//  ProductCarouselViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class ProductCarouselViewController: KeyboardViewController, AnimatableTransition {

    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var flowLayout: AnimatedPageCollectionViewLayout!
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
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var productStatusView: UIView!
    @IBOutlet weak var productStatusLabel: UILabel!
    
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
    fileprivate let viewModel: ProductCarouselViewModel
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
            bannerContainerBottomConstraint.constant = contentBottomMargin + bannerBottom
        }
    }
    fileprivate var contentBottomMargin: CGFloat = 0 {
        didSet {
            bannerContainerBottomConstraint.constant = contentBottomMargin + bannerBottom
        }
    }

    fileprivate let pageControl: UIPageControl
    fileprivate let customPageControl: PillPageControl
    fileprivate var customPageControlBottomConstraint: NSLayoutConstraint?
    fileprivate var moreInfoTooltip: Tooltip?

    fileprivate let collectionContentOffset = Variable<CGPoint>(CGPoint.zero)
    fileprivate let itemsAlpha = Variable<CGFloat>(1)
    fileprivate let cellZooming = Variable<Bool>(false)
    fileprivate let cellAnimating = Variable<Bool>(false)

    fileprivate var activeDisposeBag = DisposeBag()
    private var productInfoConstraintOffset: CGFloat = 0

    fileprivate var productOnboardingView: ProductDetailOnboardingView?
    fileprivate var didSetupAfterLayout = false
    
    fileprivate let moreInfoView: ProductCarouselMoreInfoView
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

    fileprivate var usesHorizontalNavigation: Bool {
        return viewModel.horizontalImageNavigationEnabled.value
    }


    // MARK: - Lifecycle

    convenience init(viewModel: ProductCarouselViewModel, pushAnimator: ProductCarouselPushAnimator?) {
        self.init(viewModel:viewModel,
                  pushAnimator: pushAnimator,
                  imageDownloader: ImageDownloader.sharedInstance,
                  carouselImageDownloader: ImageDownloader.make(usingImagePool: true))
    }
    
    init(viewModel: ProductCarouselViewModel,
         pushAnimator: ProductCarouselPushAnimator?,
         imageDownloader: ImageDownloaderType,
         carouselImageDownloader: ImageDownloaderType) {
        self.viewModel = viewModel
        self.userView = UserView.userView(.withProductInfo)
        let blurEffect = UIBlurEffect(style: .dark)
        self.fullScreenAvatarEffectView = UIVisualEffectView(effect: blurEffect)
        self.fullScreenAvatarView = UIImageView(frame: CGRect.zero)
        self.animator = pushAnimator
        self.pageControl = UIPageControl(frame: CGRect.zero)
        self.customPageControl = PillPageControl(frame: CGRect.zero)
        self.imageDownloader = imageDownloader
        self.carouselImageDownloader = carouselImageDownloader
        self.directAnswersView = DirectAnswersHorizontalView(answers: [], sideMargin: CarouselUI.itemsMargin,
                                                             collapsed: viewModel.quickAnswersCollapsed.value)
        self.moreInfoView = ProductCarouselMoreInfoView.moreInfoView()
        let mainBlurEffect = UIBlurEffect(style: .light)
        self.mainViewBlurEffectView = UIVisualEffectView(effect: mainBlurEffect)
        super.init(viewModel: viewModel, nibName: "ProductCarouselViewController", statusBarStyle: .lightContent,
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
        addSubviews()
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
        if viewModel.showKeyboardOnFirstAppearance {
            chatTextView.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
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
        customPageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customPageControl)
        fullScreenAvatarEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullScreenAvatarEffectView)
        userView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userView)
        fullScreenAvatarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullScreenAvatarView)
    }
    
    func setupUI() {

        if usesHorizontalNavigation {
            flowLayout.animator = PageAttributesAnimator()
        }
        
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0

        collectionView.dataSource = self
        collectionView.delegate = self
        //Duplicating registered cells to avoid reuse of colindant cells
        registerProductCarouselCells()
        collectionView.isDirectionalLockEnabled = true
        collectionView.alwaysBounceVertical = false
        automaticallyAdjustsScrollViewInsets = false

        customPageControl.backgroundColor = UIColor.clear

        CarouselUIHelper.setupPageControl(pageControl, topBarHeight: topBarHeight)

        customPageControl.layout(with: view).leading(by: CarouselUI.itemsMargin).trailing(by: -CarouselUI.itemsMargin)
        if usesHorizontalNavigation {
            customPageControl.layout().height(CarouselUI.customPageControlHeight)
            customPageControl.layout(with: buttonTop)
                .above(by: -CarouselUI.itemsMargin, constraintBlock: { [weak self] in
                    self?.customPageControlBottomConstraint = $0
                })
        } else {
            customPageControl.layout().height(0)
            customPageControl.layout(with: buttonTop)
                .above(by: 0, constraintBlock: { [weak self] in
                    self?.customPageControlBottomConstraint = $0
                })
        }

        mainViewBlurEffectView.layout(with: imageBackground).fill()
        fullScreenAvatarEffectView.layout(with: view).fill()

        userView.delegate = self

        userView.layout().height(CarouselUI.buttonHeight)
        userView.layout(with: view)
            .leading(by: CarouselUI.itemsMargin)
            .trailing(by: CarouselUI.itemsMargin, constraintBlock: { [weak self] in
                self?.userViewRightConstraint = $0
            })

        userView.layout(with: customPageControl)
            .above(by: -CarouselUI.itemsMargin, constraintBlock: { [weak self] in
                self?.userViewBottomConstraint = $0
            })

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

        CarouselUIHelper.setupShareButton(shareButton, text: LGLocalizedString.productShareNavbarButton, icon: UIImage(named:"ic_share"))

        mainResponder = chatTextView
        setupDirectMessages()
        setupBumpUpBanner()
    }

    func setupBumpUpBanner() {
        bannerContainer.addSubview(bumpUpBanner)
        bumpUpBanner.translatesAutoresizingMaskIntoConstraints = false
        bumpUpBanner.layout(with: bannerContainer).fill()
        bannerContainer.isHidden = true
    }

    private func setupMoreInfo() {
        view.addSubview(moreInfoView)
        moreInfoAlpha.asObservable().bindTo(moreInfoView.rx.alpha).addDisposableTo(disposeBag)
        moreInfoAlpha.asObservable().bindTo(moreInfoView.dragView.rx.alpha).addDisposableTo(disposeBag)

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
    
    dynamic private func backButtonClose() {
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
        viewModel.objectChanges.observeOn(MainScheduler.instance).bindNext { [weak self] change in
            guard let strongSelf = self else { return }

            self?.imageBackground.isHidden = true

            if strongSelf.usesHorizontalNavigation && strongSelf.viewModel.isMyListing {
                // when an item is updated, we have to reload all the items
                // to reassign the right zIndexes to the cells
                UIView.performWithoutAnimation {
                    self?.collectionView.reloadData()
                }
                self?.imageBackground.isHidden = false
            } else {
                self?.collectionView.handleCollectionChange(change) { _ in
                    self?.imageBackground.isHidden = false
                }
            }
        }.addDisposableTo(disposeBag)
    }

    private func setupZoomRx() {
        cellZooming.asObservable().distinctUntilChanged().bindNext { [weak self] zooming in
            UIApplication.shared.setStatusBarHidden(zooming, with: .fade)
            UIView.animate(withDuration: 0.3) {
                self?.itemsAlpha.value = zooming ? 0 : 1
                self?.moreInfoAlpha.value = zooming ? 0 : 1
                self?.navigationController?.navigationBar.alpha = zooming ? 0 : 1
            }
        }.addDisposableTo(disposeBag)
    }
    
    private func setupAlphaRxBindings() {
        itemsAlpha.asObservable().bindTo(buttonBottom.rx.alpha).addDisposableTo(disposeBag)
        itemsAlpha.asObservable().bindTo(buttonTop.rx.alpha).addDisposableTo(disposeBag)
        itemsAlpha.asObservable().bindTo(userView.rx.alpha).addDisposableTo(disposeBag)

        Observable.combineLatest(viewModel.horizontalImageNavigationEnabled.asObservable(), itemsAlpha.asObservable()) { ($0, $1) }
            .bindNext { [weak self] (horizontalNavigation, itemsAlpha) in
                self?.pageControl.alpha = horizontalNavigation ? 0 : itemsAlpha
                self?.customPageControl.alpha = horizontalNavigation ? itemsAlpha : 0
            }.addDisposableTo(disposeBag)


        itemsAlpha.asObservable().bindTo(productStatusView.rx.alpha).addDisposableTo(disposeBag)
        itemsAlpha.asObservable().bindTo(directChatTable.rx.alpha).addDisposableTo(disposeBag)
        itemsAlpha.asObservable().bindTo(chatContainer.rx.alpha).addDisposableTo(disposeBag)
        itemsAlpha.asObservable().bindTo(shareButton.rx.alpha).addDisposableTo(disposeBag)
        itemsAlpha.asObservable().bindTo(favoriteButton.rx.alpha).addDisposableTo(disposeBag)
        itemsAlpha.asObservable().bindTo(bannerContainer.rx.alpha).addDisposableTo(disposeBag)

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

        alphaSignal.bindTo(itemsAlpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(moreInfoAlpha).addDisposableTo(disposeBag)

        alphaSignal.bindNext{ [weak self] alpha in
            self?.moreInfoTooltip?.alpha = alpha
        }.addDisposableTo(disposeBag)
        
        if let navBar = navigationController?.navigationBar {
            alphaSignal.bindTo(navBar.rx.alpha).addDisposableTo(disposeBag)
        }
        
        var indexSignal: Observable<Int> = collectionContentOffset.asObservable().map { Int(($0.x + midPoint) / width) }
        
        if viewModel.startIndex != 0 {
            indexSignal = indexSignal.skip(1)
        }
        indexSignal
            .distinctUntilChanged()
            .bindNext { [weak self] index in
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
            .addDisposableTo(disposeBag)

        //Event when scroll reaches one entire page (alpha == 1) so that we can delay some tasks until then.
        alphaSignal.map { $0 == 1 }.distinctUntilChanged().filter { $0 }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .bindNext { [weak self] _ in
            self?.finishedTransition()
        }.addDisposableTo(disposeBag)
    }

    private func returnCellToFirstImage() {
        let visibleCells = collectionView.visibleCells.flatMap { $0 as? ProductCarouselCell }
        visibleCells.filter {
            guard let index = collectionView.indexPath(for: $0) else { return false }
            return index.row != viewModel.currentIndex
            }.forEach { $0.returnToFirstImage() }
    }
}


// MARK: > Configure Carousel With ProductCarouselViewModel

extension ProductCarouselViewController {

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
        setupBackgroundRx()
        setupNavigationAnimationsRx()
    }

    private func setupMoreInfoRx() {
        moreInfoView.setupWith(viewModel: viewModel)
        moreInfoState.asObservable().bindTo(viewModel.moreInfoState).addDisposableTo(disposeBag)
    }

    private func setupPageControlRx() {
        viewModel.productImageURLs.asObservable().bindNext { [weak self] images in
            guard let pageControl = self?.pageControl else { return }
            pageControl.currentPage = 0
            pageControl.numberOfPages = images.count
            pageControl.frame.size = CGSize(width: CarouselUI.pageControlWidth, height:
                pageControl.size(forNumberOfPages: images.count).width + CarouselUI.pageControlWidth)
        }.addDisposableTo(disposeBag)

        viewModel.productImageURLs.asObservable().bindNext { [weak self] images in
            guard let customPageControl = self?.customPageControl else { return }
            customPageControl.progress = 0
            customPageControl.pageCount = images.count
            let spacesSize: CGFloat = CGFloat(images.count - 1) * CarouselUI.customPageControlSpaces
            let screenWidth = UIScreen.main.bounds.width
            let pillWidth = (screenWidth - (2 * CarouselUI.itemsMargin) - spacesSize)/CGFloat(images.count)
            customPageControl.pillSize = CGSize(width: pillWidth, height: CarouselUI.customPageControlHeight)
        }.addDisposableTo(disposeBag)
    }

    fileprivate func setupUserInfoRx() {
        let productAndUserInfos = Observable.combineLatest(viewModel.productInfo.asObservable(), viewModel.userInfo.asObservable()) { $0 }
        productAndUserInfos.bindNext { [weak self] (productInfo, userInfo) in
            self?.userView.setupWith(userAvatar: userInfo?.avatar,
                                     userName: userInfo?.name,
                                     productTitle: productInfo?.title,
                                     productPrice: productInfo?.price,
                                     userId: userInfo?.userId)
        }.addDisposableTo(disposeBag)

        viewModel.userInfo.asObservable().bindNext { [weak self] userInfo in
            self?.fullScreenAvatarView.alpha = 0
            self?.fullScreenAvatarView.image = userInfo?.avatarPlaceholder
            if let avatar = userInfo?.avatar {
                let _ = self?.imageDownloader.downloadImageWithURL(avatar) { [weak self] result, url in
                    guard let imageWithSource = result.value, url == self?.viewModel.userInfo.value?.avatar else { return }
                    self?.fullScreenAvatarView.image = imageWithSource.image
                }
            }
        }.addDisposableTo(disposeBag)
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
                    shareButton.rx.tap.takeUntil(takeUntilAction).bindNext{
                        action.action()
                    }.addDisposableTo(strongSelf.disposeBag)
                    strongSelf.navigationItem.rightBarButtonItems = nil
                    strongSelf.navigationItem.rightBarButtonItem = rightItem
                default:
                    strongSelf.setLetGoRightButtonWith(action, buttonTintColor: UIColor.white,
                                                       tapBlock: { tapEvent in
                                                                tapEvent.takeUntil(takeUntilAction).bindNext{
                                                                    action.action()
                                                                }.addDisposableTo(strongSelf.disposeBag)
                                                        })
                }
            } else if navBarButtons.count > 1 {
                var buttons = [UIButton]()
                navBarButtons.forEach { navBarButton in
                    let button = UIButton(type: .system)
                    button.setImage(navBarButton.image, for: .normal)
                    button.rx.tap.takeUntil(takeUntilAction).bindNext { _ in
                        navBarButton.action()
                        }.addDisposableTo(strongSelf.disposeBag)
                    buttons.append(button)
                }
                strongSelf.setNavigationBarRightButtons(buttons)
            }
            }.addDisposableTo(disposeBag)
    }

    private func setupBottomButtonsRx() {

        Observable.combineLatest(viewModel.actionButtons.asObservable(),
                                 viewModel.horizontalImageNavigationEnabled.asObservable()) { $0 }
            .bindNext { [weak self] (actionButtons, horizontalImageNavigationEnabled) in

                guard let strongSelf = self else { return }

                strongSelf.buttonBottomHeight.constant = actionButtons.isEmpty ? 0 : CarouselUI.buttonHeight
                strongSelf.buttonTopBottomConstraint.constant = actionButtons.isEmpty ? 0 : CarouselUI.itemsMargin
                strongSelf.buttonTopHeight.constant = actionButtons.count < 2 ? 0 : CarouselUI.buttonHeight
                strongSelf.userViewBottomConstraint?.constant = (actionButtons.count < 2 && !horizontalImageNavigationEnabled) ? 0 : -CarouselUI.itemsMargin
                strongSelf.customPageControlBottomConstraint?.constant = (actionButtons.count < 2 || horizontalImageNavigationEnabled) ? 0 : -CarouselUI.itemsMargin

                guard !actionButtons.isEmpty else { return }

                let takeUntilAction = strongSelf.viewModel.actionButtons.asObservable().skip(1)
                guard let bottomAction = actionButtons.first else { return }
                strongSelf.buttonBottom.configureWith(uiAction: bottomAction)
                strongSelf.buttonBottom.rx.tap.takeUntil(takeUntilAction).bindNext {
                    bottomAction.action()
                    }.addDisposableTo(strongSelf.disposeBag)

                guard let topAction = actionButtons.last, actionButtons.count > 1 else { return }
                strongSelf.buttonTop.configureWith(uiAction: topAction)
                strongSelf.buttonTop.rx.tap.takeUntil(takeUntilAction).bindNext {
                    topAction.action()
                    }.addDisposableTo(strongSelf.disposeBag)
                
            }.addDisposableTo(disposeBag)
    }

    private func setupDirectChatElementsRx() {
        viewModel.directChatPlaceholder.asObservable().bindTo(chatTextView.rx.placeholder).addDisposableTo(disposeBag)
        chatTextView.setInitialText(LGLocalizedString.chatExpressTextFieldText)

        viewModel.directChatEnabled.asObservable().bindNext { [weak self] enabled in
            self?.buttonBottomBottomConstraint.constant = enabled ? CarouselUI.itemsMargin : 0
            self?.chatContainerHeight.constant = enabled ? CarouselUI.chatContainerMaxHeight : 0
            }.addDisposableTo(disposeBag)

        viewModel.quickAnswers.asObservable().bindNext { [weak self] quickAnswers in
            self?.directAnswersView.update(answers: quickAnswers)
        }.addDisposableTo(disposeBag)

        viewModel.directChatMessages.changesObservable.bindNext { [weak self] change in
            self?.directChatTable.handleCollectionChange(change, animation: .top)
        }.addDisposableTo(disposeBag)

        chatTextView.rx.send.bindNext { [weak self] textToSend in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.send(directMessage: textToSend, isDefaultText: strongSelf.chatTextView.isInitialText)
            strongSelf.chatTextView.clear()
        }.addDisposableTo(disposeBag)
    }

    private func setupProductStatusLabelRx() {

        let statusAndFeatured = Observable.combineLatest(viewModel.status.asObservable(), viewModel.isFeatured.asObservable()) { $0 }
        statusAndFeatured.bindNext { [weak self] (status, isFeatured) in
            if isFeatured {
                self?.productStatusView.backgroundColor = UIColor.white
                self?.productStatusLabel.text = LGLocalizedString.bumpUpProductDetailFeaturedLabel
                self?.productStatusLabel.textColor = UIColor.redText
            } else {
                self?.productStatusView.backgroundColor = status.bgColor
                self?.productStatusLabel.text = status.string
                self?.productStatusLabel.textColor = status.labelColor
            }
            self?.productStatusView.isHidden = self?.productStatusLabel.text?.isEmpty ?? true
        }.addDisposableTo(disposeBag)
    }

    private func setupFavoriteButtonRx() {
        viewModel.favoriteButtonState.asObservable()
            .bindNext { [weak self] (buttonState) in
                guard let strongButton = self?.favoriteButton else { return }
                switch buttonState {
                case .hidden:
                    strongButton.isHidden = true
                case .enabled:
                    strongButton.isHidden = false
                    strongButton.alpha = 1
                case .disabled:
                    strongButton.isHidden = false
                    strongButton.alpha = 0.6
                }
            }
            .addDisposableTo(disposeBag)

        viewModel.isFavorite.asObservable()
            .map { UIImage(named: $0 ? "ic_favorite_big_on" : "ic_favorite_big_off") }
            .bindTo(favoriteButton.rx.image).addDisposableTo(disposeBag)

        favoriteButton.rx.tap.bindNext { [weak self] in
            self?.viewModel.favoriteButtonPressed()
            }.addDisposableTo(disposeBag)
    }

    private func setupShareButtonRx() {
        viewModel.shareButtonState.asObservable().bindTo(shareButton.rx.state).addDisposableTo(disposeBag)

        shareButton.rx.tap.bindNext { [weak self] in
            self?.viewModel.shareButtonPressed()
        }.addDisposableTo(disposeBag)
    }

    private func setupBumpUpBannerRx() {
        bumpUpBanner.layoutIfNeeded()
        closeBumpUpBanner()
        viewModel.bumpUpBannerInfo.asObservable().bindNext{ [weak self] info in
            if let info = info {
                self?.showBumpUpBanner(bumpInfo: info)
            } else {
                self?.closeBumpUpBanner()
            }
        }.addDisposableTo(disposeBag)
    }

    private func setupUserInteractionRxBindings(){
        cellAnimating.asObservable().map { !$0 } .bindTo(view.rx.userInteractionEnabled).addDisposableTo(disposeBag)
    }

    private func setupBackgroundRx() {
        viewModel.horizontalImageNavigationEnabled.asObservable()
            .distinctUntilChanged().map { !$0 }
            .bindTo(mainViewBlurEffectView.rx.isHidden)
            .addDisposableTo(disposeBag)
    }

    private func setupNavigationAnimationsRx() {
        viewModel.currentViewModelIsBeingUpdated.asObservable().bindNext { [weak self] updatingVM in
            guard let strongSelf = self else { return }
            if strongSelf.usesHorizontalNavigation {
                if !updatingVM {
                    strongSelf.collectionView.translatesAutoresizingMaskIntoConstraints = false
                    strongSelf.flowLayout.animator = PageAttributesAnimator()
                } else {
                    strongSelf.collectionView.translatesAutoresizingMaskIntoConstraints = true
                    strongSelf.flowLayout.animator = nil
                }
            } else {
                strongSelf.flowLayout.animator = nil
            }
            }.addDisposableTo(disposeBag)
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


extension ProductCarouselViewController: UserViewDelegate {
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
            self?.navigationController?.navigationBar.alpha = 0
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
            self?.navigationController?.navigationBar.alpha = 1
            self?.fullScreenAvatarEffectView.alpha = 0
            self?.fullScreenAvatarView.alpha = 0
            self?.view.layoutIfNeeded()
        }) 
    }
}


// MARK: > ProductCarousel Cell Delegate

extension ProductCarouselViewController: ProductCarouselCellDelegate {

    static let animatedLayoutRubberBandOffset: CGFloat = 100
    static let defaultRubberBandOffset: CGFloat = 50

    func didTapOnCarouselCell(_ cell: UICollectionViewCell) {
        guard !chatTextView.isFirstResponder else {
            chatTextView.resignFirstResponder()
            return
        }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        cellAnimating.value = true
        let newIndexRow = indexPath.row + 1
        if newIndexRow < collectionView.numberOfItems(inSection: 0) {
            pendingMovement = .tap
            let nextIndexPath = IndexPath(item: newIndexRow, section: 0)
            collectionView.scrollToItem(at: nextIndexPath, at: .right, animated: true)
        } else {
            collectionView.showRubberBandEffect(.right,
                                                offset: usesHorizontalNavigation ?
                                                    ProductCarouselViewController.animatedLayoutRubberBandOffset :
                                                    ProductCarouselViewController.defaultRubberBandOffset)
        }
    }

    func isZooming(_ zooming: Bool) {
        cellZooming.value = zooming
    }

    func didScrollToPage(_ page: Int) {
        if viewModel.horizontalImageNavigationEnabled.value {
            customPageControl.progress = CGFloat(page)
        } else {
            pageControl.currentPage = page
        }
    }
    
    func didPullFromCellWith(_ offset: CGFloat, bottomLimit: CGFloat) {
        guard moreInfoState.value != .shown && !cellZooming.value else { return }
        if moreInfoView.frame.origin.y-offset > -view.frame.height {
            moreInfoState.value = .moving
            moreInfoView.frame.origin.y = moreInfoView.frame.origin.y-offset
        } else {
            moreInfoState.value = .hidden
            moreInfoView.frame.origin.y = -view.frame.height
        }

        let bottomOverScroll = max(offset-bottomLimit, 0)
        bottomItemsMargin = CarouselUI.itemsMargin + bottomOverScroll
    }
    
    func didEndDraggingCell() {
        if moreInfoView.frame.bottom > CarouselUI.moreInfoDragMargin*2 {
            showMoreInfo()
        } else {
            hideMoreInfo()
        }
    }
    
    func canScrollToNextPage() -> Bool {
        return moreInfoState.value == .hidden
    }
}


// MARK: > More Info

extension ProductCarouselViewController {
    
    dynamic func didTapMoreInfo() {
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
    
    func dragMoreInfoButton(_ pan: UIPanGestureRecognizer) {
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
    
    func dragViewTapped(_ tap: UITapGestureRecognizer) {
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
}


// MARK: More Info Delegate

extension ProductCarouselViewController: ProductCarouselMoreInfoDelegate {
    
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
}


// MARK: > ToolTip

extension ProductCarouselViewController {
    
    fileprivate func setupMoreInfoTooltip() {
        guard viewModel.shouldShowMoreInfoTooltip else { return }
        let tooltipText = CarouselUIHelper.buildMoreInfoTooltipText()
        let moreInfoTooltip = Tooltip(targetView: moreInfoView, superView: view, title: tooltipText,
                                      style: .blue(closeEnabled: false), peakOnTop: true,
                                      actionBlock: { [weak self] in self?.showMoreInfo() }, closeBlock: nil)
        view.addSubview(moreInfoTooltip)
        setupExternalConstraintsForTooltip(moreInfoTooltip, targetView: moreInfoView, containerView: view)
        self.moreInfoTooltip = moreInfoTooltip
    }
    
    fileprivate func removeMoreInfoTooltip() {
        moreInfoTooltip?.removeFromSuperview()
        moreInfoTooltip = nil
    }
}


// MARK: > CollectionView delegates

extension ProductCarouselViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private static let productCarouselCellCount = 3

    func registerProductCarouselCells() {
        for i in 0..<ProductCarouselViewController.productCarouselCellCount {
            collectionView.register(ProductCarouselCell.self,
                                         forCellWithReuseIdentifier: cellIdentifierForIndex(i))
        }
    }

    func cellIdentifierForIndex(_ index: Int) -> String {
        let extra = String(index % ProductCarouselViewController.productCarouselCellCount)
        return ProductCarouselCell.identifier+extra
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard didSetupAfterLayout else { return 0 }
        return viewModel.objectCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifierForIndex(indexPath.row),
                                                                             for: indexPath)
            guard let carouselCell = cell as? ProductCarouselCell else { return UICollectionViewCell() }
            guard let productCellModel = viewModel.productCellModelAt(index: indexPath.row) else { return carouselCell }
            carouselCell.configureCellWith(cellModel: productCellModel, placeholderImage: viewModel.thumbnailAtIndex(indexPath.row),
                                                  indexPath: indexPath, imageDownloader: carouselImageDownloader,
                                                  imageScrollDirection: viewModel.imageScrollDirection)
            carouselCell.delegate = self
            return carouselCell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionContentOffset.value = scrollView.contentOffset
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        cellAnimating.value = false
    }
}


// MARK: > Direct messages and stickers

extension ProductCarouselViewController: UITableViewDataSource, UITableViewDelegate, DirectAnswersHorizontalViewDelegate {
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
        chatTextView.shouldClearWhenBeginEditing = viewModel.shouldClearTextWhenBeginEditing
        chatContainer.addSubview(chatTextView)
        chatTextView.layout(with: chatContainer).leading(by: CarouselUI.itemsMargin).trailing(by: -CarouselUI.itemsMargin).bottom()
        let directAnswersBottom: CGFloat = viewModel.quickAnswersCollapsed.value ? 0 : CarouselUI.itemsMargin
        chatTextView.layout(with: directAnswersView).top(to: .bottom, by: directAnswersBottom,
                                                         constraintBlock: { [weak self] in self?.directAnswersBottom = $0 })

        keyboardChanges.bindNext { [weak self] change in
            guard let strongSelf = self else { return }
            let viewHeight = strongSelf.view.height
            self?.contentBottomMargin = viewHeight - change.origin
            UIView.animate(withDuration: Double(change.animationTime)) {
                strongSelf.view.layoutIfNeeded()
            }
        }.addDisposableTo(disposeBag)

        viewModel.quickAnswersCollapsed.asObservable().skip(1).bindNext { [weak self] collapsed in
            if !collapsed {
                self?.directAnswersView.resetScrollPosition()
            }
            self?.directAnswersView.set(collapsed: collapsed)
            self?.directAnswersBottom.constant = collapsed ? 0 : CarouselUI.itemsMargin
            UIView.animate(withDuration: LGUIKitConstants.defaultAnimationTime) {
                self?.chatContainer.superview?.layoutIfNeeded()
            }
        }.addDisposableTo(disposeBag)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.directChatMessages.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messages = viewModel.directChatMessages.value
        guard 0..<messages.count ~= indexPath.row else { return UITableViewCell() }
        let message = messages[indexPath.row]
        let drawer = ChatCellDrawerFactory.drawerForMessage(message, autoHide: true, disclosure: true)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)

        drawer.draw(cell, message: message)
        cell.transform = tableView.transform

        return cell
    }

    func directAnswersHorizontalViewDidSelect(answer: QuickAnswer) {
        viewModel.send(quickAnswer: answer)
    }

    func directAnswersHorizontalViewDidSelectClose() {
        viewModel.quickAnswersCloseButtonPressed()
    }
}


// MARK: > Bump Up bubble

extension ProductCarouselViewController {
    func showBumpUpBanner(bumpInfo: BumpUpInfo){
        guard !bumpUpBannerIsVisible else {
            // banner is already visible, but info changes
            if bumpUpBanner.type != bumpInfo.type {
                bumpUpBanner.updateInfo(info: bumpInfo)
            }
            return
        }

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


// MARK: > ProductCarouselViewModelDelegate

extension ProductCarouselViewController: ProductCarouselViewModelDelegate {

    func vmRemoveMoreInfoTooltip() {
        removeMoreInfoTooltip()
    }

    func vmShowOnboarding() {
        guard let navigationCtrlView = navigationController?.view ?? view else { return }
        let onboardingVM = ProductDetailOnboardingViewModel()
        onboardingVM.delegate = self
        productOnboardingView = ProductDetailOnboardingView(viewModel: onboardingVM)

        guard let onboarding = productOnboardingView else { return }
        navigationCtrlView.addSubview(onboarding)
        onboarding.setupUI()
        onboarding.frame = navigationCtrlView.frame
        onboarding.layoutIfNeeded()
    }

    func vmOpenCommercialDisplay(_ displayVM: CommercialDisplayViewModel) {
        let commercialDisplayVC = CommercialDisplayViewController(viewModel: displayVM)
        navigationController?.present(commercialDisplayVC, animated: true, completion: nil)
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


// MARK: - ProductDetailOnboardingViewDelegate

extension ProductCarouselViewController: ProductDetailOnboardingViewDelegate {
    func productDetailOnboardingDidAppear() {
        // nav bar behaves weird when is hidden in mainproducts list and the onboarding is shown
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func productDetailOnboardingDidDisappear() {
        // nav bar shown again, but under the onboarding
        navigationController?.setNavigationBarHidden(false, animated: false)
        productOnboardingView = nil
    }
}


// MARK: - Accessibility ids

fileprivate extension ProductCarouselViewController {
    func setAccessibilityIds() {
        collectionView.accessibilityId = .productCarouselCollectionView
        buttonBottom.accessibilityId = .productCarouselButtonBottom
        buttonTop.accessibilityId = .productCarouselButtonTop
        favoriteButton.accessibilityId = .productCarouselFavoriteButton
        moreInfoView.accessibilityId = .productCarouselMoreInfoView
        productStatusLabel.accessibilityId = .productCarouselProductStatusLabel
        directChatTable.accessibilityId = .productCarouselDirectChatTable
        fullScreenAvatarView.accessibilityId = .productCarouselFullScreenAvatarView
        pageControl.accessibilityId = .productCarouselPageControl
        customPageControl.accessibilityId = .productCarouselCustomPageControl
        userView.accessibilityId = .productCarouselUserView
        chatTextView.accessibilityId = .productCarouselChatTextView
    }
}
