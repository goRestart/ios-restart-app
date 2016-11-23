//
//  ProductCarouselViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class ProductCarouselViewController: BaseViewController, AnimatableTransition {

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
    
    @IBOutlet weak var productStatusView: UIView!
    @IBOutlet weak var productStatusLabel: UILabel!
    
    @IBOutlet weak var directChatTable: UITableView!
    @IBOutlet weak var stickersButton: UIButton!
    @IBOutlet weak var stickersButtonBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var interestedBubbleContainer: UIView!
    @IBOutlet weak var interestedBubbleContainerBottomConstraint: NSLayoutConstraint!

    private let userView: UserView
    private let fullScreenAvatarEffectView: UIVisualEffectView
    private let fullScreenAvatarView: UIImageView
    private var fullScreenAvatarWidth: NSLayoutConstraint?
    private var fullScreenAvatarHeight: NSLayoutConstraint?
    private var fullScreenAvatarTop: NSLayoutConstraint?
    private var fullScreenAvatarLeft: NSLayoutConstraint?
    private let viewModel: ProductCarouselViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private var currentIndex = 0
    private var userViewBottomConstraint: NSLayoutConstraint?
    private var userViewRightConstraint: NSLayoutConstraint?

    private var userViewRightMargin: CGFloat = CarouselUI.itemsMargin {
        didSet {
            userViewRightConstraint?.constant = -userViewRightMargin
        }
    }
    private var buttonsRightMargin: CGFloat = CarouselUI.buttonTrailingWithIcon {
        didSet {
            buttonBottomTrailingConstraint?.constant = buttonsRightMargin
            chatContainerTrailingConstraint?.constant = buttonsRightMargin
        }
    }
    private var bottomItemsMargin: CGFloat = CarouselUI.itemsMargin {
        didSet {
            chatContainerBottomConstraint?.constant = bottomItemsMargin
            stickersButtonBottomConstraint?.constant = bottomItemsMargin
        }
    }
    private var interestedBubbleBottom: CGFloat = -CarouselUI.interestedBubbleHeight {
        didSet {
            interestedBubbleContainerBottomConstraint.constant = contentBottomMargin + interestedBubbleBottom
        }
    }
    private var contentBottomMargin: CGFloat = 0 {
        didSet {
            interestedBubbleContainerBottomConstraint.constant = contentBottomMargin + interestedBubbleBottom

        }
    }

    private let pageControl: UIPageControl
    private var moreInfoTooltip: Tooltip?

    private let collectionContentOffset = Variable<CGPoint>(CGPoint.zero)
    private let cellZooming = Variable<Bool>(false)

    private var activeDisposeBag = DisposeBag()
    private var productInfoConstraintOffset: CGFloat = 0

    private var productOnboardingView: ProductDetailOnboardingView?
    private var didSetupAfterLayout = false
    
    private var moreInfoView: ProductCarouselMoreInfoView?
    private let moreInfoAlpha = Variable<CGFloat>(1)
    private let moreInfoState = Variable<MoreInfoState>(.Hidden)

    private let chatTextView = ChatTextView()

    private var interestedBubble = InterestedBubble()
    private var interestedBubbleIsVisible: Bool = false
    private var interestedBubbleTimer: NSTimer = NSTimer()

    private var expandableButtonsView: ExpandableButtonsView?

    let animator: PushAnimator?
    var pendingMovement: CarouselMovement?

    private let carouselImageDownloader: ImageDownloader = ImageDownloader.externalBuildImageDownloader(true)
    private let keyboardHelper: KeyboardHelper = KeyboardHelper.sharedInstance
    
    private let featureFlags: FeatureFlaggeable

    // MARK: - Lifecycle

    convenience init(viewModel: ProductCarouselViewModel, pushAnimator: ProductCarouselPushAnimator?) {
        let featureFlags = FeatureFlags.sharedInstance
        self.init(viewModel:viewModel, pushAnimator: pushAnimator, featureFlags: featureFlags)
    }
    
    init(viewModel: ProductCarouselViewModel, pushAnimator: ProductCarouselPushAnimator?, featureFlags: FeatureFlaggeable) {
        self.viewModel = viewModel
        self.userView = UserView.userView(.WithProductInfo)
        let blurEffect = UIBlurEffect(style: .Dark)
        self.fullScreenAvatarEffectView = UIVisualEffectView(effect: blurEffect)
        self.fullScreenAvatarView = UIImageView(frame: CGRect.zero)
        self.animator = pushAnimator
        self.pageControl = UIPageControl(frame: CGRect.zero)
        self.featureFlags = featureFlags
        super.init(viewModel: viewModel, nibName: "ProductCarouselViewController", statusBarStyle: .LightContent,
                   navBarBackgroundStyle: .Transparent(substyle: .Dark))
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

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        forceCloseInterestedBubble()
    }

    /*
     We need to setup some properties after we are sure the view has the final frame, to do that
     the animator will tell us when the view has a valid frame to configure the elements.
     `viewDidLayoutSubviews` will be called multiples times, we must assure the setup is done once only.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let animator = animator where animator.toViewValidatedFrame && !didSetupAfterLayout else { return }
        didSetupAfterLayout = true
        imageBackground.image = animator.fromViewSnapshot
        flowLayout.itemSize = view.bounds.size
        setupAlphaRxBindings()
        let startIndexPath = NSIndexPath(forItem: viewModel.startIndex, inSection: 0)
        viewModel.moveToProductAtIndex(viewModel.startIndex, delegate: self, movement: .Initial)
        currentIndex = viewModel.startIndex
        collectionView.reloadData()
        collectionView.scrollToItemAtIndexPath(startIndexPath, atScrollPosition: .Right, animated: false)

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
        collectionView.registerClass(ProductCarouselCell.self,
                                     forCellWithReuseIdentifier: cellIdentifierForIndex(0))
        collectionView.registerClass(ProductCarouselCell.self,
                                     forCellWithReuseIdentifier: cellIdentifierForIndex(1))
        collectionView.directionalLockEnabled = true
        collectionView.alwaysBounceVertical = false
        automaticallyAdjustsScrollViewInsets = false

        CarouselUIHelper.setupPageControl(pageControl, topBarHeight: topBarHeight)

        let views = ["ev": fullScreenAvatarEffectView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[ev]|", options: [], metrics: nil,
                                                                             views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[ev]|", options: [], metrics: nil,
                                                                              views: views))

        userView.delegate = self
        let leftMargin = NSLayoutConstraint(item: userView, attribute: .Leading, relatedBy: .Equal, toItem: view,
                                            attribute: .Leading, multiplier: 1, constant: CarouselUI.itemsMargin)
        let bottomMargin = NSLayoutConstraint(item: userView, attribute: .Bottom, relatedBy: .Equal, toItem: buttonTop,
                                              attribute: .Top, multiplier: 1, constant: -CarouselUI.itemsMargin)
        let rightMargin = NSLayoutConstraint(item: userView, attribute: .Trailing, relatedBy: .LessThanOrEqual,
                                             toItem: view, attribute: .Trailing, multiplier: 1,
                                             constant: -CarouselUI.itemsMargin)
        let height = NSLayoutConstraint(item: userView, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                         attribute: .NotAnAttribute, multiplier: 1, constant: 50)
        view.addConstraints([leftMargin, rightMargin, bottomMargin, height])
        userViewBottomConstraint = bottomMargin
        userViewRightConstraint = rightMargin
        
        // UserView effect
        fullScreenAvatarEffectView.alpha = 0
        fullScreenAvatarView.clipsToBounds = true
        fullScreenAvatarView.contentMode = .ScaleAspectFill
        fullScreenAvatarView.alpha = 0
        let fullAvatarWidth = NSLayoutConstraint(item: fullScreenAvatarView, attribute: .Width, relatedBy: .Equal, toItem: nil,
                                              attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        fullScreenAvatarWidth = fullAvatarWidth
        let fullAvatarHeight = NSLayoutConstraint(item: fullScreenAvatarView, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                               attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        fullScreenAvatarHeight = fullAvatarHeight
        fullScreenAvatarView.addConstraints([fullAvatarWidth, fullAvatarHeight])
        let fullAvatarTop = NSLayoutConstraint(item: fullScreenAvatarView, attribute: .Top, relatedBy: .Equal,
                                              toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        fullScreenAvatarTop = fullAvatarTop
        let fullAvatarLeft = NSLayoutConstraint(item: fullScreenAvatarView, attribute: .Left, relatedBy: .Equal,
                                               toItem: view, attribute: .Left, multiplier: 1, constant: 0)
        fullScreenAvatarLeft = fullAvatarLeft
        view.addConstraints([fullAvatarTop, fullAvatarLeft])
        userView.showShadow(false)

        productStatusView.rounded = true
        productStatusLabel.textColor = UIColor.soldColor
        productStatusLabel.font = UIFont.productStatusSoldFont

        editButton.rounded = true

        setupDirectMessagesAndStickers()
        setupInterestedBubble()
        setupExpandableButtonsViewIfNeeded()
    }

    func setupInterestedBubble() {
        interestedBubble.translatesAutoresizingMaskIntoConstraints = false
        interestedBubbleContainer.addSubview(interestedBubble)
        let views = ["bubble": interestedBubble]
        interestedBubbleContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[bubble]-0-|",
            options: [], metrics: nil, views: views))
        interestedBubbleContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[bubble]-0-|",
            options: [], metrics: nil, views: views))
    }

    private func setupExpandableButtonsViewIfNeeded() {
        guard featureFlags.productDetailShareMode == .InPlace else { return }
        guard let socialMessage = viewModel.currentProductViewModel?.socialMessage.value else { return }
        let expandableButtons = ExpandableButtonsView(buttonSide: 36, buttonSpacing: 7)
        expandableButtonsView = expandableButtons

        for type in viewModel.shareTypes {
            guard SocialSharer.canShareIn(type) else { continue }
            expandableButtons.addButton(image: type.smallImage, accessibilityId: type.accesibilityId) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.socialSharer.share(socialMessage, shareType: type, viewController: strongSelf,
                                                        barButtonItem: nil)
            }
        }

        expandableButtons.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(expandableButtons)

        view.addConstraint(NSLayoutConstraint(item: expandableButtons, attribute: .Trailing, relatedBy: .Equal,
                                              toItem: view, attribute: .Trailing, multiplier: 1, constant: -15))
        view.addConstraint(NSLayoutConstraint(item: expandableButtons, attribute: .Top, relatedBy: .Equal,
                                              toItem: view, attribute: .Top, multiplier: 1, constant: 64))
    }

    private func setupNavigationBar() {
        let backIconImage = UIImage(named: "ic_close_carousel")
        let backButton = UIBarButtonItem(image: backIconImage, style: UIBarButtonItemStyle.Plain,
                                         target: self, action: #selector(backButtonClose))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    dynamic private func backButtonClose() {
        close()
    }

    private func close() {
        if moreInfoView?.frame.origin.y < 0 {
            viewModel.close()
        } else {
            if let moreInfoView = moreInfoView where moreInfoView.bigMapVisible {
                hideBigMap()
            } else {
                hideMoreInfo()
            }
        }
    }
    
    private func setupGradientView() {
        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0.4, 0], locations: [0, 1])
        shadowLayer.frame = gradientShadowView.bounds
        gradientShadowView.layer.insertSublayer(shadowLayer, atIndex: 0)
        
        let shadowLayer2 = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0, 0.4], locations: [0, 1])
        shadowLayer.frame = gradientShadowBottomView.bounds
        gradientShadowBottomView.layer.insertSublayer(shadowLayer2, atIndex: 0)
    }

    private func setupCollectionRx() {
        viewModel.objectChanges.bindNext { [weak self] change in
            self?.collectionView.handleCollectionChange(change)
        }.addDisposableTo(disposeBag)
    }

    private func setupZoomRx() {
        cellZooming.asObservable().distinctUntilChanged().bindNext { [weak self] zooming in
            UIApplication.sharedApplication().setStatusBarHidden(zooming, withAnimation: .Fade)
            if zooming {
                self?.expandableButtonsView?.shrink(animated: true)
            }
            UIView.animateWithDuration(0.3) {
                self?.navigationController?.navigationBar.alpha = zooming ? 0 : 1
                self?.buttonBottom.alpha = zooming ? 0 : 1
                self?.buttonTop.alpha = zooming ? 0 : 1
                self?.userView.alpha = zooming ? 0 : 1
                self?.pageControl.alpha = zooming ? 0 : 1
                self?.moreInfoTooltip?.alpha = zooming ? 0 : 1
                self?.moreInfoView?.dragView.alpha = zooming ? 0 : 1
                self?.favoriteButton.alpha = zooming ? 0 : 1
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
                let midValue = fabs($0.x % width - midPoint)
                if midValue <= minMargin { return 0 }
                if midValue >= (midPoint-minMargin) { return 1}
                let newValue = (midValue - minMargin) / (midPoint - minMargin*2)
                return newValue
        }

        alphaSignal.bindTo(buttonBottom.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(userView.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(pageControl.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(buttonTop.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(productStatusView.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(moreInfoAlpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(stickersButton.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(editButton.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(directChatTable.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(chatContainer.rx_alpha).addDisposableTo(disposeBag)

        if let expandableButtonsView = expandableButtonsView {
            // Hide fav button if expandable buttons view is expanded, otherwise depend on reversed alpha
            Observable.combineLatest(expandableButtonsView.expanded.asObservable(), alphaSignal,
                                     resultSelector: { (expanded, alpha) -> CGFloat in
                                        let hideFav = expanded ? 0 : alpha
                return hideFav
            }).bindTo(favoriteButton.rx_alpha).addDisposableTo(disposeBag)

            // If expanded & we start to fade out the hide expandable buttons view
            Observable.combineLatest(expandableButtonsView.expanded.asObservable(), alphaSignal, resultSelector: { (expanded, alpha) -> Bool in
                return expanded && alpha < 1
            }).filter { $0 == true }.subscribeNext({ [weak self] _ in
                self?.expandableButtonsView?.switchExpanded(animated: true)
            }).addDisposableTo(disposeBag)
        } else {
            alphaSignal.bindTo(favoriteButton.rx_alpha).addDisposableTo(disposeBag)
        }

        alphaSignal.bindNext{ [weak self] alpha in
            self?.moreInfoTooltip?.alpha = alpha
        }.addDisposableTo(disposeBag)
        
        if let navBar = navigationController?.navigationBar {
            alphaSignal.bindTo(navBar.rx_alpha).addDisposableTo(disposeBag)
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
                    movement = .SwipeRight
                } else if index < strongSelf.currentIndex {
                    movement = .SwipeLeft
                } else {
                    movement = .Initial
                }
                if movement != .Initial {
                    self?.viewModel.moveToProductAtIndex(index, delegate: strongSelf, movement: movement)
                }
                self?.refreshOverlayElements()
                if movement == .Tap {
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

    private func refreshOverlayElements() {
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
        setupMoreInfo()
        refreshInterestedBubble(viewModel)
        refreshExpandableButtonsView()
    }

    private func finishedTransition() {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        updateMoreInfo()
    }
    
    private func setupMoreInfo() {
        if moreInfoView == nil {
            moreInfoView = ProductCarouselMoreInfoView.moreInfoView()
            if let moreInfoView = moreInfoView {
                view.addSubview(moreInfoView)
                moreInfoAlpha.asObservable().bindTo(moreInfoView.rx_alpha).addDisposableTo(disposeBag)
                moreInfoAlpha.asObservable().bindTo(moreInfoView.dragView.rx_alpha).addDisposableTo(disposeBag)
            }
            view.bringSubviewToFront(buttonBottom)
            view.bringSubviewToFront(stickersButton)
            view.bringSubviewToFront(editButton)
            view.bringSubviewToFront(chatContainer)
            view.bringSubviewToFront(interestedBubbleContainer)
            view.bringSubviewToFront(fullScreenAvatarEffectView)
            view.bringSubviewToFront(fullScreenAvatarView)
            view.bringSubviewToFront(directChatTable)
        }
        moreInfoView?.frame = view.bounds
        moreInfoView?.height = view.height + CarouselUI.moreInfoExtraHeight
        moreInfoView?.frame.origin.y = -view.bounds.height
    }

    private func updateMoreInfo() {
        guard let currentPVM = viewModel.currentProductViewModel else { return }
        moreInfoView?.setupWith(viewModel: currentPVM)
        moreInfoState.asObservable().bindTo(currentPVM.moreInfoState).addDisposableTo(activeDisposeBag)
    }

    private func setupUserView(viewModel: ProductViewModel) {
        userView.setupWith(userAvatar: viewModel.ownerAvatar,
                           userName: viewModel.ownerName,
                           productTitle: viewModel.productTitle.value,
                           productPrice: viewModel.productPrice.value,
                           userId: viewModel.ownerId)
    }

    private func setupFullScreenAvatarView(viewModel: ProductViewModel) {
        fullScreenAvatarView.alpha = 0
        fullScreenAvatarView.image = viewModel.ownerAvatarPlaceholder
        if let avatar = viewModel.ownerAvatar {
            ImageDownloader.sharedInstance.downloadImageWithURL(avatar) { [weak self] result, url in
                guard let imageWithSource = result.value where url == self?.viewModel.currentProductViewModel?.ownerAvatar else { return }
                self?.fullScreenAvatarView.image = imageWithSource.image
            }
        }
    }

    private func setupRxNavbarBindings(viewModel: ProductViewModel) {
        setNavigationBarRightButtons([])
        viewModel.navBarButtons.asObservable().subscribeNext { [weak self] navBarButtons in
            guard let strongSelf = self else { return }

            if navBarButtons.count == 1 {
                switch navBarButtons[0].interface {
                case .TextImage:
                    strongSelf.setNavigationBarRightButtonSharing(navBarButtons[0])
                default:
                    strongSelf.setLetGoRightButtonWith(navBarButtons[0], disposeBag: strongSelf.activeDisposeBag,
                        buttonTintColor: UIColor.white)
                }
            } else if navBarButtons.count > 1 {
                var buttons = [UIButton]()
                navBarButtons.forEach { navBarButton in
                    let button = UIButton(type: .System)
                    button.setImage(navBarButton.image, forState: .Normal)
                    button.rx_tap.bindNext { _ in
                        navBarButton.action()
                        }.addDisposableTo(strongSelf.activeDisposeBag)
                    buttons.append(button)
                }
                strongSelf.setNavigationBarRightButtons(buttons)
            }
        }.addDisposableTo(activeDisposeBag)
    }
    
    private func setNavigationBarRightButtonSharing(action: UIAction) {
        let shareButton = CarouselUIHelper.buildShareButton(action.text, icon: action.image)
        let rightItem = UIBarButtonItem(customView: shareButton)
        rightItem.style = .Plain
        shareButton.rx_tap.bindNext{
            action.action()
        }.addDisposableTo(activeDisposeBag)
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = rightItem
    }
    
    private func setupRxProductUpdate(viewModel: ProductViewModel) {
        viewModel.product.asObservable().bindNext { [weak self] _ in
            guard let strongSelf = self else { return }
            let visibleIndexPaths = strongSelf.collectionView.indexPathsForVisibleItems()
            //hiding fake list background to avoid showing it while the cell reloads
            self?.imageBackground.hidden = true
            strongSelf.collectionView.performBatchUpdates({ [weak self] in
                 self?.collectionView.reloadItemsAtIndexPaths(visibleIndexPaths)
            }, completion: { [weak self] _ in
                self?.imageBackground.hidden = false
            })
        }.addDisposableTo(activeDisposeBag)
    }

    private func refreshPageControl(viewModel: ProductViewModel) {
        pageControl.currentPage = 0
        pageControl.numberOfPages = viewModel.product.value.images.count
        pageControl.frame.size = CGSize(width: CarouselUI.pageControlWidth, height:
        pageControl.sizeForNumberOfPages(pageControl.numberOfPages).width + CarouselUI.pageControlWidth)
    }
    
    private func refreshBottomButtons(viewModel: ProductViewModel) {
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
            strongSelf.buttonBottom.rx_tap.takeUntil(takeUntilAction).bindNext {
                bottomAction.action()
            }.addDisposableTo(strongSelf.activeDisposeBag)

            guard let topAction = actionButtons.last where actionButtons.count > 1 else { return }
            strongSelf.buttonTop.configureWith(uiAction: topAction)
            strongSelf.buttonTop.rx_tap.takeUntil(takeUntilAction).bindNext {
                topAction.action()
            }.addDisposableTo(strongSelf.activeDisposeBag)

        }.addDisposableTo(activeDisposeBag)

        viewModel.editButtonState.asObservable().bindTo(editButton.rx_state).addDisposableTo(disposeBag)
        editButton.rx_tap.bindNext { [weak self, weak viewModel] in
            self?.hideMoreInfo()
            viewModel?.editProduct()
        }.addDisposableTo(activeDisposeBag)

        // When there's the edit/stickers button, the bottom button must adapt right margin to give space for it
        let bottomRightButtonPresent = Observable.combineLatest(
            viewModel.stickersButtonEnabled.asObservable(), viewModel.editButtonState.asObservable(),
            resultSelector: { (stickers, edit) in return stickers || (edit != .Hidden) })
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

    private func refreshProductOnboarding(viewModel: ProductViewModel) {
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
    
    private func refreshProductStatusLabel(viewModel: ProductViewModel) {
        viewModel.productStatusLabelText
            .asObservable()
            .map{ $0?.isEmpty ?? true}
            .bindTo(productStatusView.rx_hidden)
            .addDisposableTo(activeDisposeBag)
        
        viewModel.productStatusLabelText
            .asObservable()
            .map{$0 ?? ""}
            .bindTo(productStatusLabel.rx_text)
            .addDisposableTo(activeDisposeBag)
    }

    private func refreshDirectChatElements(viewModel: ProductViewModel) {
        viewModel.stickersButtonEnabled.asObservable().map { !$0 }.bindTo(stickersButton.rx_hidden).addDisposableTo(disposeBag)

        chatTextView.placeholder = viewModel.directChatPlaceholder
        chatTextView.clear()
        chatTextView.resignFirstResponder()

        viewModel.directChatEnabled.asObservable().bindNext { [weak self] enabled in
            self?.buttonBottomBottomConstraint.constant = enabled ? CarouselUI.itemsMargin : 0
            self?.chatContainerHeight.constant = enabled ? CarouselUI.buttonHeight : 0
            }.addDisposableTo(activeDisposeBag)

        chatTextView.rx_send.bindNext { [weak self, weak viewModel] textToSend in
            viewModel?.sendDirectMessage(textToSend)
            self?.chatTextView.clear()
            }.addDisposableTo(activeDisposeBag)

        viewModel.directChatMessages.changesObservable.bindNext { [weak self] change in
            self?.directChatTable.handleCollectionChange(change, animation: .Top)
            }.addDisposableTo(activeDisposeBag)
        directChatTable.reloadData()
    }

    private func refreshFavoriteButton(viewModel: ProductViewModel) {
        viewModel.favoriteButtonState.asObservable()
            .bindTo(favoriteButton.rx_state)
            .addDisposableTo(activeDisposeBag)

        viewModel.isFavorite.asObservable()
            .bindNext { [weak self] favorite in
                self?.favoriteButton.setImage(UIImage(named: favorite ? "ic_favorite_big_on" : "ic_favorite_big_off"), forState: .Normal)
            }.addDisposableTo(activeDisposeBag)

        favoriteButton.rx_tap.bindNext { [weak viewModel] in
            viewModel?.switchFavorite()
        }.addDisposableTo(activeDisposeBag)
    }

    private func refreshInterestedBubble(viewModel: ProductViewModel) {
        forceCloseInterestedBubble()
        viewModel.showInterestedBubble.asObservable().filter{$0}.bindNext{ [weak self, weak viewModel] _ in
            let text = viewModel?.interestedBubbleTitle
            self?.showInterestedBubble(text)
            }.addDisposableTo(activeDisposeBag)
    }

    private func refreshExpandableButtonsView() {
        guard let expandableButtonsView = expandableButtonsView where expandableButtonsView.expanded.value else { return }
        expandableButtonsView.switchExpanded(animated: false)
    }
}


extension ProductCarouselViewController: UserViewDelegate {
    func userViewAvatarPressed(userView: UserView) {
        viewModel.openProductOwnerProfile()
    }
    
    func userViewTextInfoContainerPressed(userView: UserView) {
        showMoreInfo()
    }

    func userViewAvatarLongPressStarted(userView: UserView) {
        view.bringSubviewToFront(fullScreenAvatarView)
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
        UIView.animateWithDuration(0.25) { [weak self] in
            self?.navigationController?.navigationBar.alpha = 0
            self?.fullScreenAvatarEffectView.alpha = 1
            self?.fullScreenAvatarView.alpha = 1
            self?.view.layoutIfNeeded()
        }
    }

    func userViewAvatarLongPressEnded(userView: UserView) {
        fullScreenAvatarLeft?.constant = userView.frame.left + userView.userAvatarImageView.frame.left
        fullScreenAvatarTop?.constant = userView.frame.top + userView.userAvatarImageView.frame.top
        fullScreenAvatarWidth?.constant = userView.userAvatarImageView.frame.size.width
        fullScreenAvatarHeight?.constant = userView.userAvatarImageView.frame.size.height
        UIView.animateWithDuration(0.25) { [weak self] in
            self?.navigationController?.navigationBar.alpha = 1
            self?.fullScreenAvatarEffectView.alpha = 0
            self?.fullScreenAvatarView.alpha = 0
            self?.view.layoutIfNeeded()
        }
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

    func vmHideExpandableShareButtons() {
        expandableButtonsView?.shrink(animated: true)
    }
}


// MARK: > ProductCarousel Cell Delegate

extension ProductCarouselViewController: ProductCarouselCellDelegate {
    func didTapOnCarouselCell(cell: UICollectionViewCell) {
        guard !chatTextView.isFirstResponder() else {
            chatTextView.resignFirstResponder()
            return
        }
        guard let indexPath = collectionView.indexPathForCell(cell) else { return }
        let newIndexRow = indexPath.row + 1
        if newIndexRow < collectionView.numberOfItemsInSection(0) {
            pendingMovement = .Tap
            let nextIndexPath = NSIndexPath(forItem: newIndexRow, inSection: 0)
            collectionView.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: .Right, animated: false)
        } else {
            collectionView.showRubberBandEffect(.Right)
        }
    }

    func isZooming(zooming: Bool) {
        cellZooming.value = zooming
    }

    func didScrollToPage(page: Int) {
        pageControl.currentPage = page
    }
    
    func didPullFromCellWith(offset: CGFloat, bottomLimit: CGFloat) {
        guard let moreInfoView = moreInfoView where moreInfoState.value != .Shown && !cellZooming.value else { return }
        if moreInfoView.frame.origin.y-offset > -view.frame.height {
            moreInfoState.value = .Moving
            moreInfoView.frame.origin.y = moreInfoView.frame.origin.y-offset
        } else {
            moreInfoState.value = .Hidden
            moreInfoView.frame.origin.y = -view.frame.height
        }

        let bottomOverScroll = max(offset-bottomLimit, 0)
        bottomItemsMargin = CarouselUI.itemsMargin + bottomOverScroll
    }
    
    func didEndDraggingCell() {
        if moreInfoView?.frame.bottom > CarouselUI.moreInfoDragMargin*2 {
            showMoreInfo()
        } else {
            hideMoreInfo()
        }
    }
    
    func canScrollToNextPage() -> Bool {
        return moreInfoState.value == .Hidden
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
    
    func dragMoreInfoButton(pan: UIPanGestureRecognizer) {
        let point = pan.locationInView(view)
        
        if point.y >= CarouselUI.moreInfoExtraHeight { // start dragging when point is below the navbar
            moreInfoView?.frame.bottom = point.y
        }
        
        switch pan.state {
        case .Ended:
            if point.y > CarouselUI.moreInfoDragMargin {
                showMoreInfo()
            } else {
                hideMoreInfo()
            }
        default:
            break
        }
    }
    
    func dragViewTapped(tap: UITapGestureRecognizer) {
        showMoreInfo()
    }
    
    @IBAction func showMoreInfo() {
        guard moreInfoState.value == .Hidden || moreInfoState.value == .Moving else { return }

        chatTextView.resignFirstResponder()
        moreInfoState.value = .Shown
        viewModel.didOpenMoreInfo()

        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: [],
                                   animations: { [weak self] in
                                    self?.moreInfoView?.frame.origin.y = 0
                                    }, completion: nil)
    }

    func hideMoreInfo() {
        guard moreInfoState.value == .Shown || moreInfoState.value == .Moving else { return }

        moreInfoState.value = .Hidden
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: [],
                                   animations: { [weak self] in
            guard let `self` = self else { return }
            self.moreInfoView?.frame.origin.y = -self.view.bounds.height
        }, completion: { [weak self] _ in
            self?.moreInfoView?.dismissed()
        })
    }

    func hideBigMap() {
        guard let moreInfoView = moreInfoView where moreInfoView.bigMapVisible else { return }
        moreInfoView.hideBigMap()
    }
}


// MARK: More Info Delegate

extension ProductCarouselViewController: ProductCarouselMoreInfoDelegate {
    
    func didEndScrolling(topOverScroll: CGFloat, bottomOverScroll: CGFloat) {
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
    
    private func setupMoreInfoTooltip() {
        guard viewModel.shouldShowMoreInfoTooltip else { return }
        guard let moreInfoView = moreInfoView else { return }
        let tooltipText = CarouselUIHelper.buildMoreInfoTooltipText()
        let moreInfoTooltip = Tooltip(targetView: moreInfoView, superView: view, title: tooltipText,
                                      style: .Blue(closeEnabled: false), peakOnTop: true,
                                      actionBlock: { [weak self] in self?.showMoreInfo() }, closeBlock: nil)
        view.addSubview(moreInfoTooltip)
        setupExternalConstraintsForTooltip(moreInfoTooltip, targetView: moreInfoView, containerView: view)
        self.moreInfoTooltip = moreInfoTooltip
    }
    
    private func removeMoreInfoTooltip() {
        moreInfoTooltip?.removeFromSuperview()
        moreInfoTooltip = nil
    }
}


// MARK: > CollectionView delegates

extension ProductCarouselViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func cellIdentifierForIndex(index: Int) -> String {
        let extra: String = (index % 2) == 0 ? "0" : "1"
        return ProductCarouselCell.identifier+extra
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard didSetupAfterLayout else { return 0 }
        return viewModel.objectCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifierForIndex(indexPath.row),
                                                                             forIndexPath: indexPath)
            guard let carouselCell = cell as? ProductCarouselCell else { return UICollectionViewCell() }
            guard let product = viewModel.productAtIndex(indexPath.row) else { return carouselCell }
            carouselCell.configureCellWithProduct(product, placeholderImage: viewModel.thumbnailAtIndex(indexPath.row),
                                                  indexPath: indexPath, imageDownloader: carouselImageDownloader)
            carouselCell.delegate = self
            return carouselCell
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell,
                        forItemAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.viewModel.setCurrentIndex(indexPath.row)
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        collectionContentOffset.value = scrollView.contentOffset
    }
}


// MARK: > Direct messages and stickers

extension ProductCarouselViewController: UITableViewDataSource, UITableViewDelegate, StickersSelectorDelegate {

    func setupDirectMessagesAndStickers() {
        ChatCellDrawerFactory.registerCells(directChatTable)
        directChatTable.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0)
        directChatTable.rowHeight = UITableViewAutomaticDimension
        directChatTable.estimatedRowHeight = 140

        chatTextView.translatesAutoresizingMaskIntoConstraints = false
        chatContainer.addSubview(chatTextView)
        let views = ["chatText": chatTextView]
        chatContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[chatText]-0-|",
            options: [], metrics: nil, views: views))
        chatContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[chatText]-0-|",
            options: [], metrics: nil, views: views))

        stickersButton.rx_tap.bindNext { [weak self] in
            self?.viewModel.currentProductViewModel?.stickersButton()
        }.addDisposableTo(disposeBag)

        var previousKbOrigin: CGFloat = CGFloat.max
        keyboardHelper.rx_keyboardOrigin.asObservable().skip(1).distinctUntilChanged().bindNext { [weak self] origin in
            guard let strongSelf = self else { return }
            let viewHeight = strongSelf.view.height
            let animationTime = strongSelf.keyboardHelper.animationTime
            guard viewHeight >= origin else { return }
            self?.contentBottomMargin = viewHeight - origin
            let showingKb = origin < previousKbOrigin
            strongSelf.chatContainerTrailingConstraint.constant = showingKb ? CarouselUI.itemsMargin : strongSelf.buttonsRightMargin
            UIView.animateWithDuration(Double(animationTime)) {
                strongSelf.stickersButton.alpha = showingKb ? 0 : 1
                strongSelf.view.layoutIfNeeded()
            }
            previousKbOrigin = origin
        }.addDisposableTo(disposeBag)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentProductViewModel?.directChatMessages.value.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let messages = viewModel.currentProductViewModel?.directChatMessages.value else { return UITableViewCell() }
        guard 0..<messages.count ~= indexPath.row else { return UITableViewCell() }
        let message = messages[indexPath.row]
        let drawer = ChatCellDrawerFactory.drawerForMessage(message, autoHide: true)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)

        drawer.draw(cell, message: message, delegate: self)
        cell.transform = tableView.transform

        return cell
    }


    // MARK: StickersSelectorDelegate

    func stickersSelectorDidSelectSticker(sticker: Sticker) {
        viewModel.currentProductViewModel?.sendSticker(sticker)
    }

    func stickersSelectorDidCancel() {}
}


// MARK: > Interested bubble

extension ProductCarouselViewController {
    func showInterestedBubble(text: String?){
        guard !interestedBubbleIsVisible else { return }
        interestedBubbleTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(timerCloseInterestedBubble),
                                                                       userInfo: nil, repeats: false)
        interestedBubbleIsVisible = true
        interestedBubble.updateInfo(text)
        delay(0.1) { [weak self] in
            self?.interestedBubbleBottom = 0
            UIView.animateWithDuration(0.3, animations: {
                self?.view.layoutIfNeeded()
            })
        }
    }

    func timerCloseInterestedBubble() {
        removeBubble(0.5)
    }

    func forceCloseInterestedBubble() {
        removeBubble(0.01)
    }

    func removeBubble(duration: NSTimeInterval) {
        guard interestedBubbleIsVisible else { return }
        interestedBubbleTimer.invalidate()
        interestedBubbleIsVisible = false
        interestedBubbleBottom = -CarouselUI.interestedBubbleHeight
        UIView.animateWithDuration(duration, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
}


// MARK: > Product View Model Delegate

extension ProductCarouselViewController: ProductViewModelDelegate {
    func vmShowShareFromMain(socialMessage: SocialMessage) {
        switch featureFlags.productDetailShareMode {
        case .Native:
            viewModel.openShare(.Native, fromViewController: self, barButtonItem: navigationItem.rightBarButtonItems?.first)
        case .InPlace:
            expandableButtonsView?.switchExpanded(animated: true)
        case .FullScreen:
            viewModel.openFullScreenShare()
        }
    }

    func vmShowShareFromMoreInfo(socialMessage: SocialMessage) {
        viewModel.openShare(.Native, fromViewController: self, barButtonItem: navigationItem.rightBarButtonItems?.first)
    }
    
    func vmOpenMainSignUp(signUpVM: SignUpViewModel, afterLoginAction: () -> ()) {
        let mainSignUpVC = MainSignUpViewController(viewModel: signUpVM)
        mainSignUpVC.afterLoginAction = afterLoginAction
        
        let navCtl = UINavigationController(rootViewController: mainSignUpVC)
        navCtl.view.backgroundColor = UIColor.whiteColor()
        presentViewController(navCtl, animated: true, completion: nil)
    }
    
    func vmOpenPromoteProduct(promoteVM: PromoteProductViewModel) {
        let promoteProductVC = PromoteProductViewController(viewModel: promoteVM)
        navigationController?.presentViewController(promoteProductVC, animated: true, completion: nil)
    }
    
    func vmOpenCommercialDisplay(displayVM: CommercialDisplayViewModel) {
        let commercialDisplayVC = CommercialDisplayViewController(viewModel: displayVM)
        navigationController?.presentViewController(commercialDisplayVC, animated: true, completion: nil)
    }

    func vmAskForRating() {
        guard let tabBarCtrl = self.tabBarController as? TabBarController else { return }
        tabBarCtrl.showAppRatingViewIfNeeded(.MarkedSold)
    }
    
    func vmShowOnboarding() {
        guard let productVM = viewModel.currentProductViewModel else { return }
        refreshProductOnboarding(productVM)
    }
    
    func vmShowProductDelegateActionSheet(cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: navigationItem.rightBarButtonItems?.first)
    }

    func vmOpenStickersSelector(stickers: [Sticker]) {
        let interlocutorName = viewModel.currentProductViewModel?.ownerName
        let vc = StickersSelectorViewController(stickers: stickers, interlocutorName: interlocutorName)
        vc.delegate = self
        navigationController?.presentViewController(vc, animated: false, completion: nil)
    }

    func vmShareDidFailedWith(error: String) {
        showAutoFadingOutMessageAlert(error)
    }

    func vmViewControllerToShowShareOptions() -> UIViewController {
        return self
    }


    // Loadings and alerts overrides to remove keyboard before showing

    override func vmShowLoading(loadingMessage: String?) {
        chatTextView.resignFirstResponder()
        super.vmShowLoading(loadingMessage)
    }

    override func vmShowAutoFadingMessage(message: String, completion: (() -> ())?) {
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

extension ProductCarouselViewController {
    private func setAccessibilityIds() {
        collectionView.accessibilityId = .ProductCarouselCollectionView
        buttonBottom.accessibilityId = .ProductCarouselButtonBottom
        buttonTop.accessibilityId = .ProductCarouselButtonTop
        favoriteButton.accessibilityId = .ProductCarouselFavoriteButton
        moreInfoView?.accessibilityId = .ProductCarouselMoreInfoView
        productStatusLabel.accessibilityId = .ProductCarouselProductStatusLabel
        directChatTable.accessibilityId = .ProductCarouselDirectChatTable
        stickersButton.accessibilityId = .ProductCarouselStickersButton
        editButton.accessibilityId = .ProductCarouselEditButton
        fullScreenAvatarView.accessibilityId = .ProductCarouselFullScreenAvatarView
        pageControl.accessibilityId = .ProductCarouselPageControl
        userView.accessibilityId = .ProductCarouselUserView
        chatTextView.accessibilityId = .ProductCarouselChatTextView
    }
}
