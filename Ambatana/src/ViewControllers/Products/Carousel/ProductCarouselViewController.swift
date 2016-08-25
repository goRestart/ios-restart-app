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
    @IBOutlet weak var favoriteButton: UIButton!

    @IBOutlet weak var moreInfoView: UIView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productStatusView: UIView!
    @IBOutlet weak var productStatusLabel: UILabel!

    @IBOutlet weak var moreInfoCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreInfoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var productInfoCenterConstraint: NSLayoutConstraint!

    @IBOutlet weak var directChatTable: UITableView!
    @IBOutlet weak var stickersButton: UIButton!
    @IBOutlet weak var stickersButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var stickersButtonTrailing: NSLayoutConstraint!

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
    private let commercialButton = CommercialButton.commercialButton()!

    private let pageControl: UIPageControl
    private let pageControlWidth: CGFloat = 18
    private let pageControlMargin: CGFloat = 18
    private let itemsMargin: CGFloat = 15
    private let moreInfoViewHeight: CGFloat = 50
    private let stickersButtonVisibleWidth: CGFloat = 50
    private let moreInfoDragMinimumSeparation: CGFloat = 100
    private let moreInfoOpeningTopMargin: CGFloat = 86
    private let moreInfoTooltipMargin: CGFloat = -10
    private var moreInfoTooltip: Tooltip?

    private var collectionContentOffset = Variable<CGPoint>(CGPoint.zero)

    private var activeDisposeBag = DisposeBag()
    private var productInfoConstraintOffset: CGFloat = 0

    private var productOnboardingView: ProductDetailOnboardingView?
    private var didSetupAfterLayout = false

    let animator: PushAnimator?
    var pendingMovement: CarouselMovement?

    private var interestedBubble: BubbleNotification?

    
    // MARK: - Init

    init(viewModel: ProductCarouselViewModel, pushAnimator: ProductCarouselPushAnimator?) {
        self.viewModel = viewModel
        self.userView = UserView.userView(.Full)
        let blurEffect = UIBlurEffect(style: .Dark)
        self.fullScreenAvatarEffectView = UIVisualEffectView(effect: blurEffect)
        self.fullScreenAvatarView = UIImageView(frame: CGRect.zero)
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

        setupMoreInfoTooltip()
    }


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupUI()
        setupMoreInfo()
        setupNavigationBar()
        setupGradientView()
        setupCollectionRx()
        setupAccessibilityIds()
    }

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
                                            attribute: .Leading, multiplier: 1, constant: itemsMargin)
        let bottomMargin = NSLayoutConstraint(item: userView, attribute: .Bottom, relatedBy: .Equal, toItem: view,
                                              attribute: .Bottom, multiplier: 1, constant: -itemsMargin)
        let rightMargin = NSLayoutConstraint(item: userView, attribute: .Trailing, relatedBy: .LessThanOrEqual,
                                             toItem: view, attribute: .Trailing, multiplier: 1,
                                             constant: -itemsMargin)
        let height = NSLayoutConstraint(item: userView, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                        attribute: .NotAnAttribute, multiplier: 1, constant: 50)
        view.addConstraints([leftMargin, rightMargin, bottomMargin, height])
        userViewBottomConstraint = bottomMargin

        view.addSubview(commercialButton)
        commercialButton.translatesAutoresizingMaskIntoConstraints = false
        let topCommercial = NSLayoutConstraint(item: commercialButton, attribute: .Top, relatedBy: .Equal, toItem: view,
                                               attribute: .Top, multiplier: 1, constant: 80)
        let rightCommercial = NSLayoutConstraint(item: commercialButton, attribute: .Trailing, relatedBy: .Equal, toItem: view,
                                                 attribute: .Trailing, multiplier: 1, constant: -itemsMargin)
        let heightCommercial = NSLayoutConstraint(item: commercialButton, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                                  attribute: .NotAnAttribute, multiplier: 1, constant: 32)
        view.addConstraints([topCommercial, rightCommercial, heightCommercial])


        // More Info
        productTitleLabel.font = UIFont.productTitleFont
        productPriceLabel.font = UIFont.productPriceFont

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

        productStatusView.layer.cornerRadius = productStatusView.height/2
        productStatusLabel.textColor = UIColor.soldColor
        productStatusLabel.font = UIFont.productStatusSoldFont

        setupDirectMessagesAndStickers()
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

    private func setupCollectionRx() {
        viewModel.objectChanges.bindNext { [weak self] change in
            self?.collectionView.handleCollectionChange(change)
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
        alphaSignal.bindTo(moreInfoView.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(productStatusView.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(commercialButton.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(stickersButton.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(directChatTable.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(favoriteButton.rx_alpha).addDisposableTo(disposeBag)
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
            action =  { viewModel.chatWithSeller() }
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

    private func setupMoreInfoTooltip() {
        guard viewModel.shouldShowMoreInfoTooltip else { return }

        let tapTextAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.white,
                                                       NSFontAttributeName : UIFont.systemBoldFont(size: 17)]
        let infoTextAttributes: [String : AnyObject] = [ NSForegroundColorAttributeName : UIColor.grayLighter,
                                                         NSFontAttributeName : UIFont.systemSemiBoldFont(size: 17)]
        let plainText = LGLocalizedString.productMoreInfoTooltipPart2(LGLocalizedString.productMoreInfoTooltipPart1)
        let resultText = NSMutableAttributedString(string: plainText, attributes: infoTextAttributes)
        let boldRange = NSString(string: plainText).rangeOfString(LGLocalizedString.productMoreInfoTooltipPart1,
                                                                  options: .CaseInsensitiveSearch)
        resultText.addAttributes(tapTextAttributes, range: boldRange)

        let moreInfoTooltip = Tooltip(targetView: moreInfoView, superView: view, title: resultText,
                                      style: .Blue(closeEnabled: false), peakOnTop: false,
                                      actionBlock: { [weak self] in self?.openMoreInfo() }, closeBlock: nil)
        view.addSubview(moreInfoTooltip)
        setupExternalConstraintsForTooltip(moreInfoTooltip, targetView: moreInfoView, containerView: view,
                                           margin: moreInfoTooltipMargin)
        self.moreInfoTooltip = moreInfoTooltip
    }

    private func removeMoreInfoTooltip() {
        moreInfoTooltip?.removeFromSuperview()
        moreInfoTooltip = nil
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
            - moreInfoView.height/2 - itemsMargin

        let bottomLimit = min(view.height-moreInfoDragMinimumSeparation, userView.top) - view.height/2
            - moreInfoView.height/2 - itemsMargin

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
        refreshMoreInfoView(viewModel)
        refreshProductStatusLabel(viewModel)
        refreshCommercialVideoButton(viewModel)
        refreshDirectChatElements(viewModel)
        refreshFavoriteButton(viewModel)
        refreshInterestedBubble(viewModel)
    }

    private func setupUserView(viewModel: ProductViewModel) {
        userView.setupWith(userAvatar: viewModel.ownerAvatar, placeholder: viewModel.ownerAvatarPlaceholder,
                           userName: viewModel.ownerName, subtitle: nil)
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

    private func setupRxProductUpdate(viewModel: ProductViewModel) {
        viewModel.product.asObservable().skip(1).bindNext { [weak self] _ in
            guard let strongSelf = self else { return }
            let visibleIndexPaths = strongSelf.collectionView.indexPathsForVisibleItems()
            strongSelf.collectionView.reloadItemsAtIndexPaths(visibleIndexPaths)
            }.addDisposableTo(activeDisposeBag)
    }

    private func refreshPageControl(viewModel: ProductViewModel) {
        pageControl.currentPage = 0
        pageControl.numberOfPages = viewModel.product.value.images.count
        pageControl.frame.size = CGSize(width: pageControlWidth, height:
            pageControl.sizeForNumberOfPages(pageControl.numberOfPages).width + pageControlWidth)
    }

    private func refreshBottomButtons(viewModel: ProductViewModel) {

        let userViewMarginAboveBottomButton = view.frame.height - buttonBottom.frame.origin.y + itemsMargin
        let userViewMarginAboveTopButton = view.frame.height - buttonTop.frame.origin.y + itemsMargin
        let userViewMarginWithoutButtons = itemsMargin

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
        viewModel.productHasReadyCommercials.asObservable()
            .map{ !$0 || FeatureFlags.bigFavoriteIcon }
            .bindTo(commercialButton.rx_hidden)
            .addDisposableTo(activeDisposeBag)

        commercialButton
            .innerButton
            .rx_tap.bindNext { viewModel.openVideo() }
            .addDisposableTo(activeDisposeBag)
    }

    private func refreshDirectChatElements(viewModel: ProductViewModel) {
        viewModel.stickersButtonEnabled.asObservable().bindNext { [weak self] enabled in
            self?.stickersButton.hidden = !enabled
            self?.stickersButtonWidth.constant = enabled ? self?.stickersButtonVisibleWidth ?? 0 : 0
            self?.stickersButtonTrailing.constant = enabled ? self?.itemsMargin ?? 0 : 0
            }.addDisposableTo(activeDisposeBag)

        viewModel.directChatMessages.changesObservable.bindNext { [weak self] change in
            self?.directChatTable.handleCollectionChange(change, animation: .Top)
            }.addDisposableTo(activeDisposeBag)
        directChatTable.reloadData()
    }

    private func refreshFavoriteButton(viewModel: ProductViewModel) {
        viewModel.productIsFavoriteable.asObservable()
            .map{!$0 || !FeatureFlags.bigFavoriteIcon}
            .bindTo(favoriteButton.rx_hidden)
            .addDisposableTo(activeDisposeBag)

        viewModel.favoriteButtonEnabled.asObservable()
            .bindTo(favoriteButton.rx_enabled)
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
        hideInterestedBubble()
        viewModel.showInterestedBubble.asObservable().filter{$0}.bindNext{ [weak self, weak viewModel] _ in
            let productId = viewModel?.product.value.objectId
            let text = viewModel?.interestedBubbleTitle
            let icon = viewModel?.interestedBubbleIcon
            self?.showInterestedBubbleForProduct(productId, text: text, icon: icon)
        }.addDisposableTo(activeDisposeBag)
    }
}


extension ProductCarouselViewController: UserViewDelegate {
    func userViewAvatarPressed(userView: UserView) {
        viewModel.openProductOwnerProfile()
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
    }

    func vmRemoveMoreInfoTooltip() {
        removeMoreInfoTooltip()
    }
}


// MARK: > ProductCarousel Cell Delegate

extension ProductCarouselViewController: ProductCarouselCellDelegate {
    func didTapOnCarouselCell(cell: UICollectionViewCell) {
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

    func didChangeZoomLevel(level: CGFloat) {
        let shouldHide = level > 1
        UIView.animateWithDuration(0.3) { [weak self] in
            self?.navigationController?.navigationBar.alpha = shouldHide ? 0 : 1
            self?.buttonBottom.alpha = shouldHide ? 0 : 1
            self?.buttonTop.alpha = shouldHide ? 0 : 1
            self?.userView.alpha = shouldHide ? 0 : 1
            self?.pageControl.alpha = shouldHide ? 0 : 1
            self?.moreInfoView.alpha = shouldHide ? 0 : 1
            self?.moreInfoTooltip?.alpha = shouldHide ? 0 : 1
        }
    }

    func didScrollToPage(page: Int) {
        pageControl.currentPage = page
    }
}


// MARK: > CollectionView delegates

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
            carouselCell.backgroundColor = UIColor.placeholderBackgroundColor(product.objectId)
            carouselCell.configureCellWithProduct(product, placeholderImage: viewModel.thumbnailAtIndex(indexPath.row),
                                                  indexPath: indexPath)
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

extension ProductCarouselViewController: UITableViewDataSource, UITableViewDelegate {

    func setupDirectMessagesAndStickers() {
        ChatCellDrawerFactory.registerCells(directChatTable)
        directChatTable.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0)
        directChatTable.rowHeight = UITableViewAutomaticDimension
        directChatTable.estimatedRowHeight = 140

        stickersButton.rx_tap.bindNext { [weak self] in
            self?.viewModel.currentProductViewModel?.stickersButton()
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
}


// MARK: > Interested bubble

extension ProductCarouselViewController {
    func showInterestedBubbleForProduct(productId: String?, text: String?, icon: UIImage?){
        guard let navView = navigationController?.view else { return }
        interestedBubble = BubbleNotification(text: text, icon: icon)
        guard let interestedBubble = interestedBubble else { return }
        interestedBubble.translatesAutoresizingMaskIntoConstraints = false

        navView.addSubview(interestedBubble)
        interestedBubble.setupOnView(navView)

        navView.bringSubviewToFront(interestedBubble)
        interestedBubble.showBubble()
    }

    func hideInterestedBubble() {
        guard let interestedBubble = interestedBubble else { return }
        interestedBubble.removeBubble()
        self.interestedBubble = nil
    }
}

// MARK: > Product View Model Delegate

extension ProductCarouselViewController: ProductViewModelDelegate {
    func vmShowNativeShare(socialMessage: SocialMessage) {
        //We have an A/B test (bigFavoriteIcon) that just leaves options button (with share inside) so we need to check this
        let navItemsCount = navigationItem.rightBarButtonItems?.count ?? 0
        let barButtonItem = navItemsCount > 1 ? navigationItem.rightBarButtonItems?[1] : navigationItem.rightBarButtonItems?.first
        presentNativeShare(socialMessage: socialMessage, delegate: viewModel, barButtonItem: barButtonItem)
    }

    func vmOpenEditProduct(editProductVM: EditProductViewModel) {
        let vc = EditProductViewController(viewModel: editProductVM)
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

    func vmOpenChat(chatVM: OldChatViewModel) {
        let chatVC = OldChatViewController(viewModel: chatVM, hidesBottomBar: false)
        navigationController?.pushViewController(chatVC, animated: true)
    }

    func vmOpenWebSocketChat(chatVM: ChatViewModel) {
        let chatVC = ChatViewController(viewModel: chatVM, hidesBottomBar: false)
        navigationController?.pushViewController(chatVC, animated: true)
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


// MARK: - StickersSelectorDelegate

extension ProductCarouselViewController: StickersSelectorDelegate {
    func stickersSelectorDidSelectSticker(sticker: Sticker) {
        viewModel.currentProductViewModel?.sendSticker(sticker)
    }
    
    func stickersSelectorDidCancel() {}
}


// MARK: - Accessibility ids

extension ProductCarouselViewController {
    private func setupAccessibilityIds() {
        collectionView.accessibilityId = .ProductCarouselCollectionView
        buttonBottom.accessibilityId = .ProductCarouselButtonBottom
        buttonTop.accessibilityId = .ProductCarouselButtonTop
        favoriteButton.accessibilityId = .ProductCarouselFavoriteButton
        moreInfoView.accessibilityId = .ProductCarouselMoreInfoView
        productTitleLabel.accessibilityId = .ProductCarouselProductTitleLabel
        productPriceLabel.accessibilityId = .ProductCarouselProductPriceLabel
        productStatusLabel.accessibilityId = .ProductCarouselProductStatusLabel
        directChatTable.accessibilityId = .ProductCarouselDirectChatTable
        stickersButton.accessibilityId = .ProductCarouselStickersButton
        fullScreenAvatarView.accessibilityId = .ProductCarouselFullScreenAvatarView
        pageControl.accessibilityId = .ProductCarouselPageControl
        commercialButton.accessibilityId = .ProductCarouselCommercialButton
    }
}
