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
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonBottom: UIButton!
    @IBOutlet weak var buttonBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTop: UIButton!
    @IBOutlet weak var buttonTopHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonTopBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatContainer: UIView!
    @IBOutlet weak var chatContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var chatContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var gradientShadowView: UIView!
    @IBOutlet weak var gradientShadowBottomView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var productStatusView: UIView!
    @IBOutlet weak var productStatusLabel: UILabel!
    
    @IBOutlet weak var directChatTable: CustomTouchesTableView!
    @IBOutlet weak var stickersButton: UIButton!
    @IBOutlet weak var stickersButtonBottomConstraint: NSLayoutConstraint!

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
    fileprivate var currentIndex = 0
    fileprivate var userViewBottomConstraint: NSLayoutConstraint?
    fileprivate var userViewRightConstraint: NSLayoutConstraint?

    fileprivate var userViewRightMargin: CGFloat = CarouselUI.itemsMargin {
        didSet {
            userViewRightConstraint?.constant = -userViewRightMargin
        }
    }
    fileprivate var buttonsRightMargin: CGFloat = CarouselUI.buttonTrailingWithIcon {
        didSet {
            buttonBottomTrailingConstraint?.constant = buttonsRightMargin
            if !chatTextView.isFirstResponder {
                chatContainerTrailingConstraint?.constant = buttonsRightMargin
            }
        }
    }
    fileprivate var bottomItemsMargin: CGFloat = CarouselUI.itemsMargin {
        didSet {
            chatContainerBottomConstraint?.constant = bottomItemsMargin
            stickersButtonBottomConstraint?.constant = bottomItemsMargin
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
    fileprivate var moreInfoTooltip: Tooltip?

    fileprivate let collectionContentOffset = Variable<CGPoint>(CGPoint.zero)
    fileprivate let cellZooming = Variable<Bool>(false)

    fileprivate var activeDisposeBag = DisposeBag()
    private var productInfoConstraintOffset: CGFloat = 0

    fileprivate var productOnboardingView: ProductDetailOnboardingView?
    fileprivate var didSetupAfterLayout = false
    
    fileprivate var moreInfoView: ProductCarouselMoreInfoView?
    fileprivate let moreInfoAlpha = Variable<CGFloat>(1)
    fileprivate let moreInfoState = Variable<MoreInfoState>(.hidden)

    fileprivate let chatTextView = ChatTextView()

    fileprivate var bumpUpBanner = BumpUpBanner()
    fileprivate var bumpUpBannerIsVisible: Bool = false

    let animator: PushAnimator?
    var pendingMovement: CarouselMovement?

    fileprivate let carouselImageDownloader: ImageDownloader = ImageDownloader.externalBuildImageDownloader(true)
    
    fileprivate let featureFlags: FeatureFlaggeable

    // MARK: - Lifecycle

    convenience init(viewModel: ProductCarouselViewModel, pushAnimator: ProductCarouselPushAnimator?) {
        let featureFlags = FeatureFlags.sharedInstance
        self.init(viewModel:viewModel, pushAnimator: pushAnimator, featureFlags: featureFlags)
    }
    
    init(viewModel: ProductCarouselViewModel, pushAnimator: ProductCarouselPushAnimator?, featureFlags: FeatureFlaggeable) {
        self.viewModel = viewModel
        self.userView = UserView.userView(.withProductInfo)
        let blurEffect = UIBlurEffect(style: .dark)
        self.fullScreenAvatarEffectView = UIVisualEffectView(effect: blurEffect)
        self.fullScreenAvatarView = UIImageView(frame: CGRect.zero)
        self.animator = pushAnimator
        self.pageControl = UIPageControl(frame: CGRect.zero)
        self.featureFlags = featureFlags
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
            moreInfoView?.viewWillShow()
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
        //TODO: We should refactor how tabBar is hidden. Maybe by using BaseViewController -> hasTabBar
        // Force tabBar to hide when view appears from background.
        self.tabBarController?.setTabBarHidden(true, animated: false)
        addIgnoreTouchesForMoreInfo()
        refreshBannerInfo()
    }

    /*
     We need to setup some properties after we are sure the view has the final frame, to do that
     the animator will tell us when the view has a valid frame to configure the elements.
     `viewDidLayoutSubviews` will be called multiples times, we must assure the setup is done once only.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let animator = animator, animator.toViewValidatedFrame && !didSetupAfterLayout else { return }
        didSetupAfterLayout = true
        imageBackground.image = animator.fromViewSnapshot
        flowLayout.itemSize = view.bounds.size
        setupAlphaRxBindings()
        let startIndexPath = IndexPath(item: viewModel.startIndex, section: 0)
        viewModel.moveToProductAtIndex(viewModel.startIndex, delegate: self, movement: .initial)
        currentIndex = viewModel.startIndex
        collectionView.reloadData()
        collectionView.scrollToItem(at: startIndexPath, at: .right, animated: false)

        setupMoreInfoDragging()
        setupMoreInfoTooltip()
    }


    // MARK: Setup
    
    func addSubviews() {
        view.addSubview(pageControl)
        fullScreenAvatarEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullScreenAvatarEffectView)
        userView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userView)
        fullScreenAvatarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullScreenAvatarView)
    }
    
    func setupUI() {
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        collectionView.dataSource = self
        collectionView.delegate = self
        //Duplicating registered cells to avoid reuse of colindant cells
        registerProductCarouselCells()
        collectionView.isDirectionalLockEnabled = true
        collectionView.alwaysBounceVertical = false
        automaticallyAdjustsScrollViewInsets = false

        CarouselUIHelper.setupPageControl(pageControl, topBarHeight: topBarHeight)

        let views = ["ev": fullScreenAvatarEffectView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[ev]|", options: [], metrics: nil,
                                                                             views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[ev]|", options: [], metrics: nil,
                                                                              views: views))

        userView.delegate = self
        let leftMargin = NSLayoutConstraint(item: userView, attribute: .leading, relatedBy: .equal, toItem: view,
                                            attribute: .leading, multiplier: 1, constant: CarouselUI.itemsMargin)
        let bottomMargin = NSLayoutConstraint(item: userView, attribute: .bottom, relatedBy: .equal, toItem: buttonTop,
                                              attribute: .top, multiplier: 1, constant: -CarouselUI.itemsMargin)
        let rightMargin = NSLayoutConstraint(item: userView, attribute: .trailing, relatedBy: .lessThanOrEqual,
                                             toItem: view, attribute: .trailing, multiplier: 1,
                                             constant: -CarouselUI.itemsMargin)
        let height = NSLayoutConstraint(item: userView, attribute: .height, relatedBy: .equal, toItem: nil,
                                         attribute: .notAnAttribute, multiplier: 1, constant: 50)
        view.addConstraints([leftMargin, rightMargin, bottomMargin, height])
        userViewBottomConstraint = bottomMargin
        userViewRightConstraint = rightMargin
        
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

        editButton.rounded = true

        CarouselUIHelper.setupShareButton(shareButton, text: LGLocalizedString.productShareNavbarButton, icon: UIImage(named:"ic_share"))

        mainResponder = chatTextView
        setupDirectMessagesAndStickers()
        setupBumpUpBanner()
    }

    func setupBumpUpBanner() {
        bannerContainer.addSubview(bumpUpBanner)
        bumpUpBanner.translatesAutoresizingMaskIntoConstraints = false
        bumpUpBanner.layout(with: bannerContainer).fill()
        bannerContainer.isHidden = true
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
        guard let moreInfoView = moreInfoView else { return }
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
            self?.collectionView.handleCollectionChange(change)
        }.addDisposableTo(disposeBag)
    }

    private func setupZoomRx() {
        cellZooming.asObservable().distinctUntilChanged().bindNext { [weak self] zooming in
            UIApplication.shared.setStatusBarHidden(zooming, with: .fade)
            UIView.animate(withDuration: 0.3) {
                self?.navigationController?.navigationBar.alpha = zooming ? 0 : 1
                self?.buttonBottom.alpha = zooming ? 0 : 1
                self?.buttonTop.alpha = zooming ? 0 : 1
                self?.userView.alpha = zooming ? 0 : 1
                self?.pageControl.alpha = zooming ? 0 : 1
                self?.moreInfoTooltip?.alpha = zooming ? 0 : 1
                self?.moreInfoView?.dragView.alpha = zooming ? 0 : 1
                self?.favoriteButton.alpha = zooming ? 0 : 1
                self?.shareButton.alpha = zooming ? 0 : 1
                self?.stickersButton.alpha = zooming ? 0 : 1
                self?.editButton.alpha = zooming ? 0 : 1
                self?.productStatusView.alpha = zooming ? 0 : 1
                self?.chatContainer.alpha = zooming ? 0 : 1
            }
        }.addDisposableTo(disposeBag)
    }
    
    private func setupAlphaRxBindings() {
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

        alphaSignal.bindTo(buttonBottom.rx.alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(userView.rx.alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(pageControl.rx.alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(buttonTop.rx.alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(productStatusView.rx.alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(moreInfoAlpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(stickersButton.rx.alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(editButton.rx.alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(directChatTable.rx.alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(chatContainer.rx.alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(shareButton.rx.alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(favoriteButton.rx.alpha).addDisposableTo(disposeBag)

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
                } else if index > strongSelf.currentIndex {
                    movement = .swipeRight
                } else if index < strongSelf.currentIndex {
                    movement = .swipeLeft
                } else {
                    movement = .initial
                }
                if movement != .initial {
                    self?.viewModel.moveToProductAtIndex(index, delegate: strongSelf, movement: movement)
                }
                self?.refreshOverlayElements()
                if movement == .tap {
                    self?.finishedTransition()
                }
                strongSelf.currentIndex = index
            }
            .addDisposableTo(disposeBag)

        //Event when scroll reaches one entire page (alpha == 1) so that we can delay some tasks until then.
        alphaSignal.map { $0 == 1 }.distinctUntilChanged().filter { $0 }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .bindNext { [weak self] _ in
            self?.finishedTransition()
        }.addDisposableTo(disposeBag)
    }
}


// MARK: > Configure Carousel With ProductViewModel

extension ProductCarouselViewController {

    fileprivate func refreshOverlayElements() {
        guard let viewModel = viewModel.currentProductViewModel else { return }
        activeDisposeBag = DisposeBag()
        setupUserView(viewModel)
        setupFullScreenAvatarView(viewModel)
        setupRxNavbarBindings(viewModel)
        setupRxProductUpdate(viewModel)
        refreshPageControl(viewModel)
        refreshProductOnboarding(viewModel)
        refreshBottomButtons(viewModel)
        refreshProductStatusLabel(viewModel)
        refreshDirectChatElements(viewModel)
        refreshFavoriteButton(viewModel)
        refreshShareButton(viewModel)
        setupMoreInfo()
        refreshBumpUpBanner(viewModel)
    }

    fileprivate func finishedTransition() {
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        updateMoreInfo()
    }
    
    private func setupMoreInfo() {
        if moreInfoView == nil {
            moreInfoView = ProductCarouselMoreInfoView.moreInfoView()
            if let moreInfoView = moreInfoView {
                view.addSubview(moreInfoView)
                moreInfoAlpha.asObservable().bindTo(moreInfoView.rx.alpha).addDisposableTo(disposeBag)
                moreInfoAlpha.asObservable().bindTo(moreInfoView.dragView.rx.alpha).addDisposableTo(disposeBag)
            }

            view.bringSubview(toFront: buttonBottom)
            view.bringSubview(toFront: stickersButton)
            view.bringSubview(toFront: editButton)
            view.bringSubview(toFront: chatContainer)
            view.bringSubview(toFront: bannerContainer)
            view.bringSubview(toFront: fullScreenAvatarEffectView)
            view.bringSubview(toFront: fullScreenAvatarView)
            view.bringSubview(toFront: directChatTable)
        }
        moreInfoView?.frame = view.bounds
        moreInfoView?.height = view.height + CarouselUI.moreInfoExtraHeight
        moreInfoView?.frame.origin.y = -view.bounds.height
    }

    fileprivate func updateMoreInfo() {
        guard let currentPVM = viewModel.currentProductViewModel else { return }
        moreInfoView?.setViewModel(currentPVM)
        moreInfoState.asObservable().bindTo(currentPVM.moreInfoState).addDisposableTo(activeDisposeBag)
    }

    fileprivate func setupUserView(_ viewModel: ProductViewModel) {
        userView.setupWith(userAvatar: viewModel.ownerAvatar,
                           userName: viewModel.ownerName,
                           productTitle: viewModel.productTitle.value,
                           productPrice: viewModel.productPrice.value,
                           userId: viewModel.ownerId)
    }

    fileprivate func setupFullScreenAvatarView(_ viewModel: ProductViewModel) {
        fullScreenAvatarView.alpha = 0
        fullScreenAvatarView.image = viewModel.ownerAvatarPlaceholder
        if let avatar = viewModel.ownerAvatar {
            ImageDownloader.sharedInstance.downloadImageWithURL(avatar) { [weak self] result, url in
                guard let imageWithSource = result.value, url == self?.viewModel.currentProductViewModel?.ownerAvatar else { return }
                self?.fullScreenAvatarView.image = imageWithSource.image
            }
        }
    }

    fileprivate func setupRxNavbarBindings(_ viewModel: ProductViewModel) {
        setNavigationBarRightButtons([])
        viewModel.navBarButtons.asObservable().subscribeNext { [weak self] navBarButtons in
            guard let strongSelf = self else { return }

            if navBarButtons.count == 1 {
                switch navBarButtons[0].interface {
                case .textImage:
                    strongSelf.setNavigationBarRightButtonSharing(navBarButtons[0])
                default:
                    strongSelf.setLetGoRightButtonWith(navBarButtons[0], disposeBag: strongSelf.activeDisposeBag,
                        buttonTintColor: UIColor.white)
                }
            } else if navBarButtons.count > 1 {
                var buttons = [UIButton]()
                navBarButtons.forEach { navBarButton in
                    let button = UIButton(type: .system)
                    button.setImage(navBarButton.image, for: .normal)
                    button.rx.tap.bindNext { _ in
                        navBarButton.action()
                        }.addDisposableTo(strongSelf.activeDisposeBag)
                    buttons.append(button)
                }
                strongSelf.setNavigationBarRightButtons(buttons)
            }
        }.addDisposableTo(activeDisposeBag)
    }
    
    private func setNavigationBarRightButtonSharing(_ action: UIAction) {
        let shareButton = CarouselUIHelper.buildShareButton(action.text, icon: action.image)
        let rightItem = UIBarButtonItem(customView: shareButton)
        rightItem.style = .plain
        shareButton.rx.tap.bindNext{
            action.action()
        }.addDisposableTo(activeDisposeBag)
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = rightItem
    }
    
    private func setupRxProductUpdate(_ viewModel: ProductViewModel) {
        viewModel.product.asObservable().bindNext { [weak self] _ in
            guard let strongSelf = self else { return }
            let visibleIndexPaths = strongSelf.collectionView.indexPathsForVisibleItems
            //hiding fake list background to avoid showing it while the cell reloads
            self?.imageBackground.isHidden = true
            strongSelf.collectionView.performBatchUpdates({ [weak self] in
                 self?.collectionView.reloadItems(at: visibleIndexPaths)
            }, completion: { [weak self] _ in
                self?.imageBackground.isHidden = false
            })
        }.addDisposableTo(activeDisposeBag)
    }

    private func refreshPageControl(_ viewModel: ProductViewModel) {
        pageControl.currentPage = 0
        pageControl.numberOfPages = viewModel.product.value.images.count
        pageControl.frame.size = CGSize(width: CarouselUI.pageControlWidth, height:
        pageControl.size(forNumberOfPages: pageControl.numberOfPages).width + CarouselUI.pageControlWidth)
    }
    
    private func refreshBottomButtons(_ viewModel: ProductViewModel) {
        viewModel.actionButtons.asObservable().bindNext { [weak self, weak viewModel] actionButtons in
            guard let strongSelf = self, let viewModel = viewModel else { return }

            strongSelf.buttonBottomHeight.constant = actionButtons.isEmpty ? 0 : CarouselUI.buttonHeight
            strongSelf.buttonTopBottomConstraint.constant = actionButtons.isEmpty ? 0 : CarouselUI.itemsMargin
            strongSelf.buttonTopHeight.constant = actionButtons.count < 2 ? 0 : CarouselUI.buttonHeight
            strongSelf.userViewBottomConstraint?.constant = actionButtons.count < 2 ? 0 : -CarouselUI.itemsMargin

            guard !actionButtons.isEmpty else { return }

            let takeUntilAction = viewModel.actionButtons.asObservable().skip(1)
            guard let bottomAction = actionButtons.first else { return }
            strongSelf.buttonBottom.configureWith(uiAction: bottomAction)
            strongSelf.buttonBottom.rx.tap.takeUntil(takeUntilAction).bindNext {
                bottomAction.action()
            }.addDisposableTo(strongSelf.activeDisposeBag)

            guard let topAction = actionButtons.last, actionButtons.count > 1 else { return }
            strongSelf.buttonTop.configureWith(uiAction: topAction)
            strongSelf.buttonTop.rx.tap.takeUntil(takeUntilAction).bindNext {
                topAction.action()
            }.addDisposableTo(strongSelf.activeDisposeBag)

        }.addDisposableTo(activeDisposeBag)

        viewModel.editButtonState.asObservable().bindTo(editButton.rx.state).addDisposableTo(disposeBag)
        editButton.rx.tap.bindNext { [weak self, weak viewModel] in
            self?.hideMoreInfo()
            viewModel?.editProduct()
        }.addDisposableTo(activeDisposeBag)

        // When there's the edit/stickers button, the bottom button must adapt right margin to give space for it
        let bottomRightButtonPresent = Observable.combineLatest(
            viewModel.stickersButtonEnabled.asObservable(), viewModel.editButtonState.asObservable(),
            resultSelector: { (stickers, edit) in return stickers || (edit != .hidden) })
        bottomRightButtonPresent.bindNext { [weak self] present in
            self?.buttonsRightMargin = present ? CarouselUI.buttonTrailingWithIcon : CarouselUI.itemsMargin
        }.addDisposableTo(activeDisposeBag)

        // When there's the edit/stickers button and there are no actionButtons, header is at bottom and must not overlap edit button
        let userViewCollapsed = Observable.combineLatest(
            bottomRightButtonPresent, viewModel.actionButtons.asObservable(), viewModel.directChatEnabled.asObservable(),
            resultSelector: { (buttonPresent, actionButtons, directChat) in return buttonPresent && actionButtons.isEmpty && !directChat })
        userViewCollapsed.bindNext { [weak self] collapsed in
            self?.userViewRightMargin = collapsed ? CarouselUI.buttonTrailingWithIcon : CarouselUI.itemsMargin
        }.addDisposableTo(activeDisposeBag)
    }

    fileprivate func refreshProductOnboarding(_ viewModel: ProductViewModel) {
        guard  let navigationCtrlView = navigationController?.view ?? view else { return }
        guard self.viewModel.shouldShowOnboarding else { return }
        // if state is nil, means there's no need to show the onboarding
        productOnboardingView = ProductDetailOnboardingView.instanceFromNibWithState()

        guard let onboarding = productOnboardingView else { return }
        onboarding.delegate = self
        navigationCtrlView.addSubview(onboarding)
        onboarding.setupUI()
        onboarding.frame = navigationCtrlView.frame
        onboarding.layoutIfNeeded()
    }
    
    private func refreshProductStatusLabel(_ viewModel: ProductViewModel) {
        viewModel.productStatusLabelText
            .asObservable()
            .map{ $0?.isEmpty ?? true}
            .bindTo(productStatusView.rx.isHidden)
            .addDisposableTo(activeDisposeBag)
        
        viewModel.productStatusLabelText
            .asObservable()
            .map{$0 ?? ""}
            .bindTo(productStatusLabel.rx.text)
            .addDisposableTo(activeDisposeBag)
    }
    

    private func refreshDirectChatElements(_ viewModel: ProductViewModel) {
        viewModel.stickersButtonEnabled.asObservable().map { !$0 }.bindTo(stickersButton.rx.isHidden).addDisposableTo(disposeBag)
        chatTextView.placeholder = viewModel.directChatPlaceholder
        chatTextView.setInitialText(LGLocalizedString.chatExpressTextFieldText)

        viewModel.directChatEnabled.asObservable().bindNext { [weak self] enabled in
            self?.buttonBottomBottomConstraint.constant = enabled ? CarouselUI.itemsMargin : 0
            self?.chatContainerHeight.constant = enabled ? CarouselUI.buttonHeight : 0
            }.addDisposableTo(activeDisposeBag)

        chatTextView.rx.send.bindNext { [weak self, weak viewModel] textToSend in
            guard let strongSelf = self else { return }
            viewModel?.sendDirectMessage(textToSend, isDefaultText: strongSelf.chatTextView.isInitialText)
            strongSelf.chatTextView.clear()
            }.addDisposableTo(activeDisposeBag)

        viewModel.directChatMessages.changesObservable.bindNext { [weak self] change in
            self?.directChatTable.handleCollectionChange(change, animation: .top)
            }.addDisposableTo(activeDisposeBag)
        directChatTable.reloadData()
    }

    private func refreshFavoriteButton(_ viewModel: ProductViewModel) {
        viewModel.favoriteButtonState.asObservable()
            .bindTo(favoriteButton.rx.state)
            .addDisposableTo(activeDisposeBag)

        viewModel.isFavorite.asObservable()
            .bindNext { [weak self] favorite in
                self?.favoriteButton.setImage(UIImage(named: favorite ? "ic_favorite_big_on" : "ic_favorite_big_off"), for: .normal)
            }.addDisposableTo(activeDisposeBag)

        favoriteButton.rx.tap.bindNext { [weak viewModel] in
            viewModel?.switchFavorite()
        }.addDisposableTo(activeDisposeBag)
    }

    private func refreshShareButton(_ viewModel: ProductViewModel) {
        viewModel.shareButtonState.asObservable()
            .bindTo(shareButton.rx.state)
            .addDisposableTo(activeDisposeBag)

        shareButton.rx.tap.bindNext { [weak viewModel] in
            viewModel?.shareProduct()
        }.addDisposableTo(activeDisposeBag)
    }

    private func refreshBumpUpBanner(_ viewModel: ProductViewModel) {
        bumpUpBanner.layoutIfNeeded()
        closeBumpUpBanner()
        viewModel.bumpUpBannerInfo.asObservable().bindNext{ [weak self] info in
            self?.showBumpUpBanner(bumpInfo: info)
            }.addDisposableTo(activeDisposeBag)
    }

    fileprivate func refreshBannerInfo() {
        viewModel.refreshBannerInfo()
    }
}


extension ProductCarouselViewController: UserViewDelegate {
    func userViewAvatarPressed(_ userView: UserView) {
        viewModel.openProductOwnerProfile()
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


// MARK: > ProductCarouselViewModelDelegate

extension ProductCarouselViewController: ProductCarouselViewModelDelegate {
    func vmRefreshCurrent() {
        refreshOverlayElements()
        updateMoreInfo()
    }

    func vmRemoveMoreInfoTooltip() {
        removeMoreInfoTooltip()
    }
}


// MARK: > ProductCarousel Cell Delegate

extension ProductCarouselViewController: ProductCarouselCellDelegate {
    func didTapOnCarouselCell(_ cell: UICollectionViewCell) {
        guard !chatTextView.isFirstResponder else {
            chatTextView.resignFirstResponder()
            return
        }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let newIndexRow = indexPath.row + 1
        if newIndexRow < collectionView.numberOfItems(inSection: 0) {
            pendingMovement = .tap
            let nextIndexPath = IndexPath(item: newIndexRow, section: 0)
            collectionView.scrollToItem(at: nextIndexPath, at: .right, animated: false)
        } else {
            collectionView.showRubberBandEffect(.right)
        }
    }

    func isZooming(_ zooming: Bool) {
        cellZooming.value = zooming
    }

    func didScrollToPage(_ page: Int) {
        pageControl.currentPage = page
    }
    
    func didPullFromCellWith(_ offset: CGFloat, bottomLimit: CGFloat) {
        guard let moreInfoView = moreInfoView, moreInfoState.value != .shown && !cellZooming.value else { return }
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
        guard let moreInfoView = moreInfoView else { return }
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
    
    func setupMoreInfoDragging() {
        guard let button = moreInfoView?.dragView else { return }
        self.navigationController?.navigationBar.ignoreTouchesFor(button)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragMoreInfoButton))
        button.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dragViewTapped))
        button.addGestureRecognizer(tap)
        moreInfoView?.delegate = self
    }
    
    func dragMoreInfoButton(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: view)
        
        if point.y >= CarouselUI.moreInfoExtraHeight { // start dragging when point is below the navbar
            moreInfoView?.frame.bottom = point.y
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

        moreInfoView?.viewWillShow()
        chatTextView.resignFirstResponder()
        moreInfoState.value = .shown
        viewModel.didOpenMoreInfo()

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: [],
                                   animations: { [weak self] in
                                    self?.moreInfoView?.frame.origin.y = 0
                                    }, completion: nil)
    }

    func hideMoreInfo() {
        guard moreInfoState.value == .shown || moreInfoState.value == .moving else { return }

        moreInfoState.value = .hidden
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: [],
                                   animations: { [weak self] in
            guard let `self` = self else { return }
            self.moreInfoView?.frame.origin.y = -self.view.bounds.height
        }, completion: { [weak self] _ in
            self?.moreInfoView?.dismissed()
        })
    }

    func compressMap() {
        guard let moreInfoView = moreInfoView, moreInfoView.mapExpanded else { return }
        moreInfoView.compressMap()
    }

    func addIgnoreTouchesForMoreInfo() {
        guard let button = moreInfoView?.dragView else { return }
        self.navigationController?.navigationBar.ignoreTouchesFor(button)
    }

    func removeIgnoreTouchesForMoreInfo() {
        guard let button = moreInfoView?.dragView else { return }
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

    func requestFocus() {
        chatTextView.resignFirstResponder()
    }
}


// MARK: > ToolTip

extension ProductCarouselViewController {
    
    fileprivate func setupMoreInfoTooltip() {
        guard viewModel.shouldShowMoreInfoTooltip else { return }
        guard let moreInfoView = moreInfoView else { return }
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
            guard let product = viewModel.productAtIndex(indexPath.row) else { return carouselCell }
            carouselCell.configureCellWithProduct(product, placeholderImage: viewModel.thumbnailAtIndex(indexPath.row),
                                                  indexPath: indexPath, imageDownloader: carouselImageDownloader)
            carouselCell.delegate = self
            return carouselCell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.setCurrentIndex(indexPath.row)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionContentOffset.value = scrollView.contentOffset
    }
}


// MARK: > Direct messages and stickers

extension ProductCarouselViewController: UITableViewDataSource, UITableViewDelegate, StickersSelectorDelegate {

    func setupDirectMessagesAndStickers() {
        ChatCellDrawerFactory.registerCells(directChatTable)
        directChatTable.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        directChatTable.rowHeight = UITableViewAutomaticDimension
        directChatTable.estimatedRowHeight = 140
        directChatTable.isCellHiddenBlock = { return $0.contentView.isHidden }
        directChatTable.didSelectRowAtIndexPath = {  [weak self] _ in self?.viewModel.openChatWithSeller() }

        chatTextView.translatesAutoresizingMaskIntoConstraints = false
        chatContainer.addSubview(chatTextView)
        let views = ["chatText": chatTextView]
        chatContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[chatText]-0-|",
            options: [], metrics: nil, views: views))
        chatContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[chatText]-0-|",
            options: [], metrics: nil, views: views))

        stickersButton.rx.tap.bindNext { [weak self] in
            self?.viewModel.currentProductViewModel?.stickersButton()
        }.addDisposableTo(disposeBag)

        keyboardChanges.bindNext { [weak self] change in
            guard let strongSelf = self else { return }
            let viewHeight = strongSelf.view.height
            self?.contentBottomMargin = viewHeight - change.origin
            strongSelf.chatContainerTrailingConstraint.constant = change.visible ? CarouselUI.itemsMargin : strongSelf.buttonsRightMargin
            UIView.animate(withDuration: Double(change.animationTime)) {
                strongSelf.stickersButton.alpha = change.visible ? 0 : 1
                strongSelf.view.layoutIfNeeded()
            }
        }.addDisposableTo(disposeBag)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentProductViewModel?.directChatMessages.value.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let messages = viewModel.currentProductViewModel?.directChatMessages.value else { return UITableViewCell() }
        guard 0..<messages.count ~= indexPath.row else { return UITableViewCell() }
        let message = messages[indexPath.row]
        let drawer = ChatCellDrawerFactory.drawerForMessage(message, autoHide: true, disclosure: true)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)

        drawer.draw(cell, message: message)
        cell.transform = tableView.transform

        return cell
    }


    // MARK: StickersSelectorDelegate

    func stickersSelectorDidSelectSticker(_ sticker: Sticker) {
        viewModel.currentProductViewModel?.sendSticker(sticker)
    }

    func stickersSelectorDidCancel() {}
}


// MARK: > Bump Up bubble

extension ProductCarouselViewController {
    func showBumpUpBanner(bumpInfo: BumpUpInfo?){
        guard let actualBumpInfo = bumpInfo else { return }
        guard !bumpUpBannerIsVisible else { return }
        bannerContainer.bringSubview(toFront: bumpUpBanner)
        bumpUpBannerIsVisible = true
        bannerContainer.isHidden = false
        bumpUpBanner.updateInfo(info: actualBumpInfo)
        delay(0.1) { [weak self] in
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

// MARK: > Product View Model Delegate

extension ProductCarouselViewController: ProductViewModelDelegate {
    
    func vmShowShareFromMain(_ socialMessage: SocialMessage) {
        viewModel.openShare(.native(restricted: false), fromViewController: self, barButtonItem: navigationItem.rightBarButtonItems?.first)
    }

    func vmShowShareFromMoreInfo(_ socialMessage: SocialMessage) {
        viewModel.openShare(.native(restricted: false), fromViewController: self, barButtonItem: navigationItem.rightBarButtonItems?.first)
    }
    
    func vmOpenMainSignUp(_ signUpVM: SignUpViewModel, afterLoginAction: @escaping () -> ()) {
        let mainSignUpVC = MainSignUpViewController(viewModel: signUpVM)
        mainSignUpVC.afterLoginAction = afterLoginAction
        
        let navCtl = UINavigationController(rootViewController: mainSignUpVC)
        navCtl.view.backgroundColor = UIColor.white
        present(navCtl, animated: true, completion: nil)
    }
    
    func vmOpenPromoteProduct(_ promoteVM: PromoteProductViewModel) {
        let promoteProductVC = PromoteProductViewController(viewModel: promoteVM)
        navigationController?.present(promoteProductVC, animated: true, completion: nil)
    }
    
    func vmOpenCommercialDisplay(_ displayVM: CommercialDisplayViewModel) {
        let commercialDisplayVC = CommercialDisplayViewController(viewModel: displayVM)
        navigationController?.present(commercialDisplayVC, animated: true, completion: nil)
    }

    func vmAskForRating() {
        guard let tabBarCtrl = self.tabBarController as? TabBarController else { return }
        tabBarCtrl.showAppRatingViewIfNeeded(.markedSold)
    }
    
    func vmShowOnboarding() {
        guard let productVM = viewModel.currentProductViewModel else { return }
        refreshProductOnboarding(productVM)
    }
    
    func vmShowProductDelegateActionSheet(_ cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: navigationItem.rightBarButtonItems?.first)
    }

    func vmOpenStickersSelector(_ stickers: [Sticker]) {
        let interlocutorName = viewModel.currentProductViewModel?.ownerName
        let vc = StickersSelectorViewController(stickers: stickers, interlocutorName: interlocutorName)
        vc.delegate = self
        navigationController?.present(vc, animated: false, completion: nil)
    }

    func vmShareDidFailedWith(_ error: String) {
        showAutoFadingOutMessageAlert(error)
    }

    func vmViewControllerToShowShareOptions() -> UIViewController {
        return self
    }

    // Bump Up

    func vmShowFreeBumpUpView() {
        viewModel.openFreeBumpUpView()
    }

    func vmShowPaymentBumpUpView() {
        viewModel.openPaymentBumpUpView()
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
        moreInfoView?.accessibilityId = .productCarouselMoreInfoView
        productStatusLabel.accessibilityId = .productCarouselProductStatusLabel
        directChatTable.accessibilityId = .productCarouselDirectChatTable
        stickersButton.accessibilityId = .productCarouselStickersButton
        editButton.accessibilityId = .productCarouselEditButton
        fullScreenAvatarView.accessibilityId = .productCarouselFullScreenAvatarView
        pageControl.accessibilityId = .productCarouselPageControl
        userView.accessibilityId = .productCarouselUserView
        chatTextView.accessibilityId = .productCarouselChatTextView
    }
}
