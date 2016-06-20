//
//  ProductCarouselViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

enum ProductDetailButtonType {
    case MarkAsSold
    case SellItAgain
    case CreateCommercial
    case ChatWithSeller
    case ContinueChatting
    case Cancel
}

protocol AnimatableTransition {
    var animator: PushAnimator? { get }
}


class ProductCarouselViewController: BaseViewController, AnimatableTransition {
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonBottom: UIButton!
    @IBOutlet weak var buttonTop: UIButton!
    @IBOutlet weak var gradientShadowView: UIView!
    @IBOutlet weak var gradientShadowBottomView: UIView!
    
    @IBOutlet weak var moreInfoView: UIView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productStatusView: UIView!
    @IBOutlet weak var productStatusLabel: UILabel!
    
    @IBOutlet weak var moreInfoCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreInfoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var productInfoCenterConstraint: NSLayoutConstraint!
    
    private let userView: UserView
    private let fullScreenAvatarEffectView: UIVisualEffectView
    private let fullScreenAvatarView: UIImageView
    private let loadingTimer: LoadingTimer
    private let passThroughView: PassThroughView
    private let viewModel: ProductCarouselViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private var currentIndex = 0
    private var userViewBottomConstraint: NSLayoutConstraint?
    private let commercialButton = CommercialButton.commercialButton()!

    private let pageControl: UIPageControl
    private let pageControlWidth: CGFloat = 18
    private let pageControlMargin: CGFloat = 18
    private let userViewMargin: CGFloat = 15
    private let loadingViewDiameter: CGFloat = 30
    private let loadingViewMargin: CGFloat = 15
    private let moreInfoDragMargin: CGFloat = 15
    private let moreInfoViewHeight: CGFloat = 50
    private let moreInfoDragMinimumSeparation: CGFloat = 100
    private let moreInfoOpeningTopMargin: CGFloat = 86
    
    private var activeDisposeBag = DisposeBag()
    private var productInfoConstraintOffset: CGFloat = 0

    private var productOnboardingView: ProductDetailOnboardingView?
    private var didSetupAfterLayout = false

    let animator: PushAnimator?
    var didJustTap: Bool = false
    var didJustSwitchAuto: Bool = false
    
    // MARK: - Init
    
    init(viewModel: ProductCarouselViewModel, pushAnimator: ProductCarouselPushAnimator?) {
        self.viewModel = viewModel
        self.userView = UserView.userView(.Full)
        let blurEffect = UIBlurEffect(style: .Dark)
        self.fullScreenAvatarEffectView = UIVisualEffectView(effect: blurEffect)
        self.fullScreenAvatarView = UIImageView(frame: CGRect.zero)
        self.loadingTimer = LoadingTimer(frame: CGRect(x: 0, y: 0, width: loadingViewDiameter, height: loadingViewDiameter))
        self.passThroughView = PassThroughView()
        self.animator = pushAnimator
        self.pageControl = UIPageControl(frame: CGRect.zero)
        super.init(viewModel: viewModel, nibName: "ProductCarouselViewController", statusBarStyle: .LightContent,
                   navBarBackgroundStyle: .Transparent)
        self.viewModel.delegate = self
        hidesBottomBarWhenPushed = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        loadingTimerCleanup()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientShadowView.layer.sublayers?.forEach{ $0.frame = gradientShadowView.bounds }
        gradientShadowBottomView.layer.sublayers?.forEach{ $0.frame = gradientShadowBottomView.bounds }
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
        flowLayout.itemSize = view.bounds.size
        setupAlphaRxBindings()
        let startIndexPath = NSIndexPath(forItem: viewModel.startIndex, inSection: 0)
        viewModel.moveToProductAtIndex(viewModel.startIndex, delegate: self, movement: .Initial)
        currentIndex = viewModel.startIndex
        collectionView.reloadData()
        collectionView.scrollToItemAtIndexPath(startIndexPath, atScrollPosition: .Right, animated: false)
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupUI()
        setupMoreInfo()
        setupNavigationBar()
        setupGradientView()
        setupLoadingTimer()
    }
    
    func addSubviews() {
        view.addSubview(pageControl)
        fullScreenAvatarEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullScreenAvatarEffectView)
        userView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userView)
        fullScreenAvatarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullScreenAvatarView)
        loadingTimer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingTimer)
    }
    
    func setupUI() {
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(ProductCarouselCell.self,
                                     forCellWithReuseIdentifier: ProductCarouselCell.identifier)
        collectionView.directionalLockEnabled = true
        collectionView.alwaysBounceVertical = false
        automaticallyAdjustsScrollViewInsets = false
        
        pageControl.autoresizingMask = [.FlexibleRightMargin, .FlexibleBottomMargin]
        pageControl.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        pageControl.frame.origin = CGPoint(x: pageControlMargin, y: topBarHeight + pageControlMargin)
        pageControl.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageControl.hidesForSinglePage = true
        pageControl.layer.cornerRadius = pageControlWidth/2
        pageControl.clipsToBounds = true

        let views = ["ev": fullScreenAvatarEffectView]
        let blurHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[ev]|", options: [], metrics: nil,
                                                                             views: views)
        view.addConstraints(blurHConstraints)
        let blurVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[ev]|", options: [], metrics: nil,
                                                                              views: views)
        view.addConstraints(blurVConstraints)

        userView.delegate = self
        let leftMargin = NSLayoutConstraint(item: userView, attribute: .Leading, relatedBy: .Equal, toItem: view,
                                            attribute: .Leading, multiplier: 1, constant: userViewMargin)
        let bottomMargin = NSLayoutConstraint(item: userView, attribute: .Bottom, relatedBy: .Equal, toItem: view,
                                              attribute: .Bottom, multiplier: 1, constant: -userViewMargin)
        let rightMargin = NSLayoutConstraint(item: userView, attribute: .Trailing, relatedBy: .LessThanOrEqual,
                                             toItem: loadingTimer, attribute: .Leading, multiplier: 1, constant: -userViewMargin)
        let height = NSLayoutConstraint(item: userView, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                         attribute: .NotAnAttribute, multiplier: 1, constant: 50)
        view.addConstraints([leftMargin, rightMargin, bottomMargin, height])
        userViewBottomConstraint = bottomMargin

        let loadingWidth = NSLayoutConstraint(item: loadingTimer, attribute: .Width, relatedBy: .Equal, toItem: nil,
                                              attribute: .NotAnAttribute, multiplier: 1, constant: 30)
        let loadingHeight = NSLayoutConstraint(item: loadingTimer, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                              attribute: .NotAnAttribute, multiplier: 1, constant: 30)
        loadingTimer.addConstraints([loadingWidth, loadingHeight])
        let loadingRight = NSLayoutConstraint(item: loadingTimer, attribute: .Trailing, relatedBy: .Equal,
                                              toItem: view, attribute: .Trailing, multiplier: 1, constant: -loadingViewMargin)
        let loadingBottom = NSLayoutConstraint(item: loadingTimer, attribute: .Bottom, relatedBy: .Equal,
                                               toItem: userView, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraints([loadingRight, loadingBottom])
        
        view.addSubview(commercialButton)
        commercialButton.translatesAutoresizingMaskIntoConstraints = false
        let topCommercial = NSLayoutConstraint(item: commercialButton, attribute: .Top, relatedBy: .Equal, toItem: view,
                                     attribute: .Top, multiplier: 1, constant: 80)
        let rightCommercial = NSLayoutConstraint(item: commercialButton, attribute: .Trailing, relatedBy: .Equal, toItem: view,
                                       attribute: .Trailing, multiplier: 1, constant: -userViewMargin)
        let heightCommercial = NSLayoutConstraint(item: commercialButton, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                        attribute: .NotAnAttribute, multiplier: 1, constant: 32)
        view.addConstraints([topCommercial, rightCommercial, heightCommercial])
        
        
        // More Info
        productTitleLabel.font = StyleHelper.productTitleFont
        productPriceLabel.font = StyleHelper.productPriceFont

        // UserView effect
        fullScreenAvatarEffectView.alpha = 0
        fullScreenAvatarView.clipsToBounds = true
        fullScreenAvatarView.contentMode = .ScaleAspectFill
        fullScreenAvatarView.alpha = 0
        
        userView.showShadow(false)
        
        productStatusView.layer.cornerRadius = productStatusView.height/2
        productStatusLabel.textColor = StyleHelper.soldColor
        productStatusLabel.font = StyleHelper.productStatusSoldFont
    }
    
    private func setupNavigationBar() {
        let backIcon = UIImage(named: "ic_close_carousel")
        setNavBarBackButton(backIcon)
    }
    
    private func setupGradientView() {
        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0.4, 0], locations: [0, 1])
        shadowLayer.frame = gradientShadowView.bounds
        gradientShadowView.layer.insertSublayer(shadowLayer, atIndex: 0)
        
        let shadowLayer2 = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0, 0.4], locations: [0, 1])
        shadowLayer.frame = gradientShadowBottomView.bounds
        gradientShadowBottomView.layer.insertSublayer(shadowLayer2, atIndex: 0)
    }
    
    private func setupAlphaRxBindings() {
        let width = view.bounds.width
        let midPoint = width/2
        let minMargin = midPoint * 0.15
    
        let alphaSignal: Observable<CGFloat> = collectionView.rx_contentOffset
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
        alphaSignal.bindTo(moreInfoView.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(productStatusView.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(commercialButton.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(loadingTimer.rx_alpha).addDisposableTo(disposeBag)
        
        if let navBar = navigationController?.navigationBar {
            alphaSignal.bindTo(navBar.rx_alpha).addDisposableTo(disposeBag)
        }
        
        var indexSignal: Observable<Int> = collectionView.rx_contentOffset.map { Int(($0.x + midPoint) / width) }
        
        if viewModel.startIndex != 0 {
            indexSignal = indexSignal.skip(1)
        }
        indexSignal
            .distinctUntilChanged()
            .bindNext { [weak self] index in
                guard let strongSelf = self else { return }
                let movement: CarouselMovement
                if strongSelf.didJustTap {
                    movement = .Tap
                    self?.didJustTap = false
                } else if strongSelf.didJustSwitchAuto {
                    movement = .Auto
                    self?.didJustSwitchAuto = false
                } else if index >= strongSelf.currentIndex {
                    movement = .SwipeRight
                } else {
                    movement = .SwipeLeft
                }
                self?.viewModel.moveToProductAtIndex(index, delegate: strongSelf, movement: movement)
                self?.refreshOverlayElements(movement)
                strongSelf.currentIndex = index
            }
            .addDisposableTo(disposeBag)
    }
    
    private func configureButton(button: UIButton, type: ProductDetailButtonType, viewModel: ProductViewModel) {
        button.hidden = false
        var action: (() -> ())?
        switch type {
        case .MarkAsSold:
            button.setTitle(LGLocalizedString.productMarkAsSoldButton, forState: .Normal)
            button.setStyle(.Terciary)
            action = viewModel.markSold
        case .SellItAgain:
            button.setTitle(LGLocalizedString.productSellAgainButton, forState: .Normal)
            button.setStyle(.Secondary(fontSize: .Big, withBorder: false))
            action = viewModel.resell
        case .CreateCommercial:
            button.setTitle(LGLocalizedString.productCreateCommercialButton, forState: .Normal)
            button.setStyle(.Primary(fontSize: .Big))
            action = viewModel.promoteProduct
        case .ChatWithSeller:
            button.setTitle(LGLocalizedString.productChatWithSellerButton, forState: .Normal)
            button.setStyle(.Primary(fontSize: .Big))
            action =  { viewModel.ask(nil) }
        case .ContinueChatting:
            button.setTitle(LGLocalizedString.productContinueChattingButton, forState: .Normal)
            button.setStyle(.Secondary(fontSize: .Big, withBorder: false))
        case .Cancel:
            button.setTitle(LGLocalizedString.commonCancel, forState: .Normal)
            button.setStyle(.Secondary(fontSize: .Big, withBorder: false))
        }
        
        button.rx_tap.takeUntil(viewModel.status.asObservable().skip(1)).bindNext {
            action?()
        }.addDisposableTo(activeDisposeBag)
    }
}


// MARK: - More Info

extension ProductCarouselViewController {
    private func setupMoreInfo() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openMoreInfo))
        moreInfoView.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(moreInfoDragged))
        moreInfoView.addGestureRecognizer(pan)
    }
    
    func openMoreInfo() {
        guard let productViewModel = viewModel.currentProductViewModel else { return }
        viewModel.didTapMoreInfoBar()
        let originalCenterConstantCopy = moreInfoCenterConstraint.constant
        let vc = ProductCarouselMoreInfoViewController(viewModel: productViewModel) { [weak self] view in
            guard let strongSelf = self else { return }
            self?.moreInfoHeightConstraint.constant = strongSelf.moreInfoViewHeight
            self?.productInfoCenterConstraint.constant = 0
            self?.moreInfoCenterConstraint.constant = originalCenterConstantCopy
            
            UIView.animateWithDuration(0.1) { view.alpha = 0 }
            
            UIView.animateWithDuration(0.3) {
                self?.moreInfoView.alpha = 1
                self?.view.layoutIfNeeded()
            }
            
            delay(0.3) {
                UIView.animateWithDuration(0.2) { self?.navigationController?.navigationBar.alpha = 1 }
                self?.dismissViewControllerAnimated(false, completion: nil)
            }
        }
        
        moreInfoHeightConstraint.constant = view.height
        productInfoCenterConstraint.constant = -(view.height/2 - moreInfoOpeningTopMargin)
        moreInfoCenterConstraint.constant = 0
        UIView.animateWithDuration(0.2) { [weak self] in
            self?.view.layoutIfNeeded()
            self?.navigationController?.navigationBar.alpha = 0
        }
        
        delay(0.1) { [weak self] in
            UIView.animateWithDuration(0.3) { self?.moreInfoView.alpha = 0 }
            self?.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func moreInfoDragged(gesture: UIPanGestureRecognizer) {
        
        let topLimit = view.height/2 - max(moreInfoDragMinimumSeparation, pageControl.bottom)
            - moreInfoView.height/2 - moreInfoDragMargin
        
        let bottomLimit = min(view.height-moreInfoDragMinimumSeparation, userView.top) - view.height/2
            - moreInfoView.height/2 - moreInfoDragMargin
        
        guard -topLimit < bottomLimit else { return }
        
        let translatedPoint = gesture.translationInView(view)
        if gesture.state == .Began  {
            productInfoConstraintOffset = moreInfoCenterConstraint.constant
        }
        let newConstant = productInfoConstraintOffset + translatedPoint.y
        if Int(-topLimit)..<Int(bottomLimit) ~= Int(newConstant) {
            moreInfoCenterConstraint.constant = newConstant
        }
    }
}


// MARK: > Configure Carousel With ProductViewModel

extension ProductCarouselViewController {

    private func refreshOverlayElements(lastMovement: CarouselMovement) {
        guard let viewModel = viewModel.currentProductViewModel else { return }
        activeDisposeBag = DisposeBag()
        setupUserView(viewModel)
        setupFullScreenAvatarView(viewModel)
        setupRxNavbarBindings(viewModel)
        refreshPageControl(viewModel)
        refreshProductOnboarding(viewModel)
        refreshBottomButtons(viewModel)
        refreshMoreInfoView(viewModel)
        refreshProductStatusLabel(viewModel)
        refreshCommercialVideoButton(viewModel)
        startAutoNextItem(lastMovement)
    }

    private func setupUserView(viewModel: ProductViewModel) {
        userView.setupWith(userAvatar: viewModel.ownerAvatar, placeholder: viewModel.ownerAvatarPlaceholder,
                           userName: viewModel.ownerName, subtitle: nil)
    }

    private func setupFullScreenAvatarView(viewModel: ProductViewModel) {
        fullScreenAvatarView.alpha = 0
        fullScreenAvatarView.image = viewModel.ownerAvatarPlaceholder
        if let avatar = viewModel.ownerAvatar {
            fullScreenAvatarView.lg_setImageWithURL(avatar)
        }
    }

    private func setupRxNavbarBindings(viewModel: ProductViewModel) {
        setNavigationBarRightButtons([])
        viewModel.navBarButtons.asObservable().subscribeNext { [weak self] navBarButtons in
            guard let strongSelf = self else { return }
            
            var buttons = [UIButton]()
            navBarButtons.forEach { navBarButton in
                let button = UIButton(type: .System)
                button.setImage(navBarButton.image, forState: .Normal)
                button.rx_tap.bindNext { _ in
                    navBarButton.action()
                    }.addDisposableTo(strongSelf.disposeBag)
                buttons.append(button)
            }
            strongSelf.setNavigationBarRightButtons(buttons)
            }.addDisposableTo(activeDisposeBag)
    }
    
    private func refreshPageControl(viewModel: ProductViewModel) {
        pageControl.currentPage = 0
        pageControl.numberOfPages = viewModel.product.value.images.count
        pageControl.frame.size = CGSize(width: pageControlWidth, height:
        pageControl.sizeForNumberOfPages(pageControl.numberOfPages).width + pageControlWidth)
    }
    
    private func refreshBottomButtons(viewModel: ProductViewModel) {
        
        let userViewMarginAboveBottomButton = view.frame.height - buttonBottom.frame.origin.y + userViewMargin
        let userViewMarginAboveTopButton = view.frame.height - buttonTop.frame.origin.y + userViewMargin
        let userViewMarginWithoutButtons = userViewMargin
        
        guard buttonBottom.frame.origin.y > 0 else { return }
        
        viewModel.status.asObservable().subscribeNext { [weak self] status in
            
            guard let strongSelf = self else { return }
            
            self?.buttonTop.hidden = true
            self?.buttonBottom.hidden = true
            self?.userViewBottomConstraint?.constant = -(userViewMarginAboveBottomButton)
            
            switch status {
            case .Pending, .NotAvailable, .OtherSold:
                self?.userViewBottomConstraint?.constant = -userViewMarginWithoutButtons
            case .PendingAndCommercializable:
                self?.configureButton(strongSelf.buttonBottom, type: .CreateCommercial, viewModel: viewModel)
            case .Available:
                self?.configureButton(strongSelf.buttonBottom, type: .MarkAsSold, viewModel: viewModel)
            case .AvailableAndCommercializable:
                self?.configureButton(strongSelf.buttonBottom, type: .MarkAsSold, viewModel: viewModel)
                self?.configureButton(strongSelf.buttonTop, type: .CreateCommercial, viewModel: viewModel)
                self?.userViewBottomConstraint?.constant = -(userViewMarginAboveTopButton)
            case .Sold:
                self?.configureButton(strongSelf.buttonBottom, type: .SellItAgain, viewModel: viewModel)
            case .OtherAvailable:
                self?.configureButton(strongSelf.buttonBottom, type: .ChatWithSeller, viewModel: viewModel)
            }
        }.addDisposableTo(activeDisposeBag)
    }

    private func refreshProductOnboarding(viewModel: ProductViewModel) {
        guard  let navigationCtrlView = navigationController?.view ?? view else { return }
        guard let onboardingState = self.viewModel.onboardingState else { return }
        // if state is nil, means there's no need to show the onboarding
        productOnboardingView = ProductDetailOnboardingView
            .instanceFromNibWithState(onboardingState, showChatsStep: self.viewModel.onboardingShouldShowChatsStep)

        guard let onboarding = productOnboardingView else { return }
        onboarding.delegate = self
        navigationCtrlView.addSubview(onboarding)
        onboarding.setupUI()
        onboarding.frame = navigationCtrlView.frame
        onboarding.layoutIfNeeded()
    }

    private func refreshMoreInfoView(viewModel: ProductViewModel) {
        viewModel.productTitle.asObservable().map{$0 ?? ""}
            .bindTo(productTitleLabel.rx_text).addDisposableTo(activeDisposeBag)
        viewModel.productPrice.asObservable().bindTo(productPriceLabel.rx_text).addDisposableTo(activeDisposeBag)
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
    
    private func refreshCommercialVideoButton(viewModel: ProductViewModel) {
        viewModel.productHasReadyCommercials
            .asObservable()
            .map{!$0}
            .bindTo(commercialButton.rx_hidden)
            .addDisposableTo(activeDisposeBag)
        
        commercialButton
            .innerButton
            .rx_tap.bindNext { viewModel.openVideo() }
            .addDisposableTo(activeDisposeBag)
    }
}


extension ProductCarouselViewController: UserViewDelegate {
    func userViewAvatarPressed(userView: UserView) {
        viewModel.openProductOwnerProfile()
    }

    func userViewAvatarLongPressStarted(userView: UserView) {
        fullScreenAvatarView.frame = CGRect(x: userView.frame.left + userView.userAvatarImageView.frame.left,
                                            y: userView.frame.top + userView.userAvatarImageView.frame.top,
                                            width: userView.userAvatarImageView.frame.size.width,
                                            height: userView.userAvatarImageView.frame.size.height)

        UIView.animateWithDuration(0.25) { [weak self] in
            guard let view = self?.view else { return }

            self?.navigationController?.navigationBar.alpha = 0
            self?.fullScreenAvatarEffectView.alpha = 1
            let viewSide = min(view.frame.width, view.frame.height)
            self?.fullScreenAvatarView.frame = CGRect(x: view.frame.centerX - viewSide/2,
                                                      y: view.frame.centerY - viewSide/2,
                                                      width: viewSide,
                                                      height: viewSide)
            self?.fullScreenAvatarView.alpha = 1
        }
    }

    func userViewAvatarLongPressEnded(userView: UserView) {
        UIView.animateWithDuration(0.25) { [weak self] in
            self?.navigationController?.navigationBar.alpha = 1
            self?.fullScreenAvatarEffectView.alpha = 0
            self?.fullScreenAvatarView.frame = CGRect(x: userView.frame.left + userView.userAvatarImageView.frame.left,
                                                      y: userView.frame.top + userView.userAvatarImageView.frame.top,
                                                      width: userView.userAvatarImageView.frame.size.width,
                                                      height: userView.userAvatarImageView.frame.size.height)
            self?.fullScreenAvatarView.alpha = 0
        }
    }
}


extension ProductCarouselViewController: ProductCarouselViewModelDelegate {
    func vmReloadData() {
        collectionView.reloadData()
    }
}


// MARK: > ProductCarousel Cell Delegate

extension ProductCarouselViewController: ProductCarouselCellDelegate {
    func didTapOnCarouselCell(cell: UICollectionViewCell) {
        let indexPath = collectionView.indexPathForCell(cell)!
        let newIndexRow = indexPath.row + 1
        if newIndexRow < collectionView.numberOfItemsInSection(0) {
            didJustTap = true
            let nextIndexPath = NSIndexPath(forItem: newIndexRow, inSection: 0)
            collectionView.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: .Right, animated: false)
        } else {
            collectionView.showRubberBandEffect(.Right)
        }
    }
    
    func didChangeZoomLevel(level: CGFloat) {
        let shouldHide = level > 1
        UIView.animateWithDuration(0.3) { [weak self] in
            self?.navigationController?.navigationBar.alpha = shouldHide ? 0 : 1
            self?.buttonBottom.alpha = shouldHide ? 0 : 1
            self?.buttonTop.alpha = shouldHide ? 0 : 1
            self?.userView.alpha = shouldHide ? 0 : 1
            self?.pageControl.alpha = shouldHide ? 0 : 1
            self?.moreInfoView.alpha = shouldHide ? 0 : 1
        }
    }
    
    func didScrollToPage(page: Int) {
        pageControl.currentPage = page
    }
}


// MARK: > CollectionView Data Source

extension ProductCarouselViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard didSetupAfterLayout else { return 0 }
        return viewModel.objectCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProductCarouselCell.identifier,
                                                                             forIndexPath: indexPath)
            guard let carouselCell = cell as? ProductCarouselCell else { return UICollectionViewCell() }
            guard let product = viewModel.productAtIndex(indexPath.row) else { return carouselCell }
            carouselCell.backgroundColor = StyleHelper.productCellImageBgColor
            carouselCell.configureCellWithProduct(product, placeholderImage: viewModel.thumbnailAtIndex(indexPath.row),
                                                  indexPath: indexPath)
            carouselCell.delegate = self
            return carouselCell
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell,
                        forItemAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.viewModel.setCurrentItemIndex(indexPath.row)
        }
    }
}


// MARK: > Product View Model Delegate

extension ProductCarouselViewController: ProductViewModelDelegate {
    func vmShowNativeShare(socialMessage: SocialMessage) {
        presentNativeShare(socialMessage: socialMessage, delegate: self)
    }
    
    func vmOpenEditProduct(editProductVM: EditProductViewModel) {
        let vc = EditProductViewController(viewModel: editProductVM, updateDelegate:
            viewModel.currentProductViewModel)
        let navCtl = UINavigationController(rootViewController: vc)
        navigationController?.presentViewController(navCtl, animated: true, completion: nil)
    }
    
    func vmOpenMainSignUp(signUpVM: SignUpViewModel, afterLoginAction: () -> ()) {
        let mainSignUpVC = MainSignUpViewController(viewModel: signUpVM)
        mainSignUpVC.afterLoginAction = afterLoginAction
        
        let navCtl = UINavigationController(rootViewController: mainSignUpVC)
        navCtl.view.backgroundColor = UIColor.whiteColor()
        presentViewController(navCtl, animated: true, completion: nil)
    }
    
    func vmOpenUser(userVM: UserViewModel) {
        let vc = UserViewController(viewModel: userVM)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func vmOpenChat(chatVM: OldChatViewModel) {
        let chatVC = OldChatViewController(viewModel: chatVM, hidesBottomBar: false)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func vmOpenWebSocketChat(chatVM: ChatViewModel) {
        let chatVC = ChatViewController(viewModel: chatVM, hidesBottomBar: false)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func vmOpenOffer(offerVC: MakeAnOfferViewController) {
        navigationController?.pushViewController(offerVC, animated: true)
    }
    
    func vmOpenPromoteProduct(promoteVM: PromoteProductViewModel) {
        let promoteProductVC = PromoteProductViewController(viewModel: promoteVM)
        promoteProductVC.delegate = self
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
}


// MARK: > Native Share Delegate

extension ProductCarouselViewController: NativeShareDelegate {
    
    func nativeShareInFacebook() {
        viewModel.currentProductViewModel?.shareInFacebook(.Top)
        viewModel.currentProductViewModel?.shareInFBCompleted()
    }
    
    func nativeShareInTwitter() {
        viewModel.currentProductViewModel?.shareInTwitterActivity()
    }
    
    func nativeShareInEmail() {
        viewModel.currentProductViewModel?.shareInEmail(.Top)
    }
    
    func nativeShareInWhatsApp() {
        viewModel.currentProductViewModel?.shareInWhatsappActivity()
    }
}

extension ProductCarouselViewController: PromoteProductViewControllerDelegate {
    func promoteProductViewControllerDidFinishFromSource(promotionSource: PromotionSource) {}
    func promoteProductViewControllerDidCancelFromSource(promotionSource: PromotionSource) {}
}


extension ProductCarouselViewController: ProductDetailOnboardingViewDelegate {
    func productDetailOnboardingFirstPageDidAppear() {
        // nav bar behaves weird when is hidden in mainproducts list and the onboarding is shown
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func productDetailOnboardingFirstPageDidDisappear() {
        // nav bar shown again, but under the onboarding
        navigationController?.setNavigationBarHidden(false, animated: false)
        guard let navigationCtrlView = navigationController?.view ?? view, onboarding = productOnboardingView else { return }
        navigationCtrlView.bringSubviewToFront(onboarding)
    }
}


// MARK: - Auto next item

extension ProductCarouselViewController {

    private func setupLoadingTimer() {
        passThroughView.onTouch = { [weak self] in
            self?.loadingTimerStop()
        }
        navigationController?.view.addSubview(passThroughView)
    }

    private func loadingTimerCleanup() {
        passThroughView.removeFromSuperview()
    }

    private func startAutoNextItem(lastMovement: CarouselMovement) {
        guard lastMovement != .SwipeLeft && viewModel.autoSwitchToNextEnabled else {
            loadingTimerStop()
            return
        }
        loadingTimer.hidden = false
        loadingTimer.start(3) { [weak self] in
            self?.switchAutoToNextItem()
        }
    }

    private func switchAutoToNextItem() {
        guard let indexPath = collectionView.indexPathsForVisibleItems().first else { return }
        let newIndexRow = indexPath.row + 1
        if newIndexRow < collectionView.numberOfItemsInSection(0) {
            didJustSwitchAuto = true
            let nextIndexPath = NSIndexPath(forItem: newIndexRow, inSection: 0)
            collectionView.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: .Right, animated: false)
        } else {
            collectionView.showRubberBandEffect(.Right)
        }
    }

    private func loadingTimerStop() {
        loadingTimer.stop()
        loadingTimer.hidden = true
    }
}
