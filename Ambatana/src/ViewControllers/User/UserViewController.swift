//
//  UserViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import CHTCollectionViewWaterfallLayout
import LGCoreKit
import RxCocoa
import RxSwift

class UserViewController: BaseViewController {
    fileprivate static let navBarUserViewHeight: CGFloat = 36
    private static let userBgViewDefaultHeight: CGFloat = headerExpandedHeight

    fileprivate static let productListViewTopMargin: CGFloat = 64

    fileprivate static let headerExpandedBottom: CGFloat = -(headerExpandedHeight+userBgViewDefaultHeight)
    fileprivate static let headerExpandedHeight: CGFloat = 150

    fileprivate static let headerCollapsedBottom: CGFloat = -(20+44+UserViewController.headerCollapsedHeight) // 20 status bar + 44 fake nav bar + 44 header buttons
    fileprivate static let headerCollapsedHeight: CGFloat = 44

    fileprivate static let navbarHeaderMaxThresold: CGFloat = 0.5
    fileprivate static let userLabelsMinThreshold: CGFloat = 0.5
    fileprivate static let headerMinThreshold: CGFloat = 0.7
    fileprivate static let userLabelsAndHeaderMaxThreshold: CGFloat = 1.5

    fileprivate static let userBgTintViewHeaderExpandedAlpha: CGFloat = 0.54
    fileprivate static let userBgTintViewHeaderCollapsedAlpha: CGFloat = 1.0

    fileprivate static let userEffectViewHeaderExpandedDoubleAlpha: CGFloat = 0.0
    fileprivate static let userEffectViewHeaderExpandedAlpha: CGFloat = 1.0
    fileprivate static let userEffectViewHeaderCollapsedAlpha: CGFloat = 1.0

    fileprivate static let ratingAverageContainerHeightVisible: CGFloat = 30
    
    fileprivate static let userLabelsContainerMarginLong: CGFloat = 90
    fileprivate static let userLabelsContainerMarginShort: CGFloat = 50

    fileprivate var navBarUserView: UserView
    fileprivate var navBarUserViewAlpha: CGFloat = 0.0 {
        didSet {
            navBarUserView.alpha = navBarUserViewAlpha
        }
    }

    @IBOutlet weak var patternView: UIView!
    @IBOutlet weak var userBgView: UIView!
    @IBOutlet weak var userBgEffectView: UIVisualEffectView!

    @IBOutlet weak var headerContainer: UserViewHeaderContainer!
    @IBOutlet weak var headerContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var headerContainerHeight: NSLayoutConstraint!
    fileprivate let headerGestureRecognizer: UIPanGestureRecognizer
    fileprivate let headerRecognizerDragging = Variable<Bool>(false)
    
    @IBOutlet weak var productListViewBackgroundView: UIView!
    @IBOutlet weak var productListView: ProductListView!

    @IBOutlet weak var userLabelsContainer: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var averageRatingContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var averageRatingView: UIView!
    @IBOutlet var userLabelsSideMargin: [NSLayoutConstraint]!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userBgImageView: UIImageView!
    @IBOutlet weak var userBgTintView: UIView!

    fileprivate var bottomInset: CGFloat = 0
    fileprivate let cellDrawer: ProductCellDrawer
    fileprivate var viewModel: UserViewModel
    fileprivate let socialSharer: SocialSharer

    fileprivate let headerExpandedPercentage = Variable<CGFloat>(1)
    fileprivate let disposeBag: DisposeBag
    fileprivate var notificationsManager: NotificationsManager
    fileprivate var featureFlags: FeatureFlaggeable


    // MARK: - Lifecycle

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: UserViewModel, hidesBottomBarWhenPushed: Bool = false, notificationsManager: NotificationsManager, featureFlags: FeatureFlaggeable) {
        self.notificationsManager = notificationsManager
        self.featureFlags = featureFlags
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: UserViewController.navBarUserViewHeight)
        self.navBarUserView = UserView.userView(.compactBorder(size: size))
        self.headerGestureRecognizer = UIPanGestureRecognizer()
        self.viewModel = viewModel
        let socialSharer = SocialSharer()
        socialSharer.delegate = viewModel
        self.socialSharer = socialSharer
        self.cellDrawer = ProductCellDrawer()
        self.disposeBag = DisposeBag()
        
        super.init(viewModel: viewModel, nibName: "UserViewController", statusBarStyle: .lightContent,
                   navBarBackgroundStyle: .transparent(substyle: .light))
        
        self.viewModel.delegate = self
        self.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        self.automaticallyAdjustsScrollViewInsets = false
        self.hasTabBar = viewModel.isMyProfile
    }
    
    convenience init(viewModel: UserViewModel, hidesBottomBarWhenPushed: Bool = false) {
        let notificationsManager = NotificationsManager.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        self.init(viewModel: viewModel, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed, notificationsManager: notificationsManager, featureFlags: featureFlags)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let tabBarCtl = tabBarController {
            bottomInset = tabBarCtl.tabBar.isHidden ? 0 : tabBarCtl.tabBar.frame.height
        }
        else {
            bottomInset = 0
        }

        setupUI()
        setupAccessibilityIds()
        setupRxBindings()
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        view.backgroundColor = viewModel.backgroundColor.value
      
        
        // UINavigationBar's title alpha gets resetted on view appear, does not allow initial 0.0 value
        let currentAlpha: CGFloat = navBarUserViewAlpha
        navBarUserView.isHidden = true
        delay(0.01) { [weak self] in
            self?.navBarUserView.alpha = currentAlpha
            self?.navBarUserView.isHidden = false
        }
    }
    
    override func viewWillDisappearToBackground(_ toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)

        // Animating to clear background color as it glitches next screen translucent navBar
        // http://stackoverflow.com/questions/28245061/why-does-setting-hidesbottombarwhenpushed-to-yes-with-a-translucent-navigation
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.backgroundColor = UIColor.white
        }) 
    }
}


// MARK: - ProductsRefreshable

extension UserViewController: ProductsRefreshable {
    func productsRefresh() {
        viewModel.refreshSelling()
    }
}


// MARK: - ProductListViewScrollDelegate

extension UserViewController: ProductListViewScrollDelegate {
    func productListView(_ productListView: ProductListView, didScrollDown scrollDown: Bool) {
    }

    func productListView(_ productListView: ProductListView, didScrollWithContentOffsetY contentOffsetY: CGFloat) {
        scrollDidChange(contentOffsetY)
    }
}


// MARK: - UserViewModelDelegate

extension UserViewController: UserViewModelDelegate {
    func vmOpenReportUser(_ reportUserVM: ReportUsersViewModel) {
        let vc = ReportUsersViewController(viewModel: reportUserVM)
        navigationController?.pushViewController(vc, animated: true)
    }

    func vmOpenHome() {
        guard let tabBarCtl = tabBarController as? TabBarController else { return }
        tabBarCtl.switchToTab(.home)
    }
    
    func vmShowUserActionSheet(_ cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: navigationItem.rightBarButtonItem)
    }

    func vmShowNativeShare(_ socialMessage: SocialMessage) {
        socialSharer.share(socialMessage, shareType: .native, viewController: self, barButtonItem: navigationItem.rightBarButtonItems?.first)
    }
    
    func vmOpenFavorites() {
        headerContainer.header?.setFavoriteTab()
    }
}


// MARK: - UserViewModelDelegate

extension UserViewController : UserViewHeaderDelegate {
    func headerAvatarAction() {
        viewModel.avatarButtonPressed()
    }

    func ratingsAvatarAction() {
        viewModel.ratingsButtonPressed()
    }

    func buildTrustAction() {
        viewModel.buildTrustButtonPressed()
    }
}


// MARK: - Private methods
// MARK: - UI

extension UserViewController {
    fileprivate func setupUI() {
        setupMainView()
        setupHeader()
        setupNavigationBar()
        setupProductListView()
    }

    fileprivate func setupAccessibilityIds() {
        navBarUserView.titleLabel.accessibilityId = .userHeaderCollapsedNameLabel
        navBarUserView.subtitleLabel.accessibilityId = .userHeaderCollapsedLocationLabel
        userNameLabel.accessibilityId = .userHeaderExpandedNameLabel
        userLocationLabel.accessibilityId = .userHeaderExpandedLocationLabel

        headerContainer?.header?.avatarButton.accessibilityId = .userHeaderExpandedAvatarButton
        headerContainer?.header?.ratingsButton.accessibilityId = .userHeaderExpandedRatingsButton
        headerContainer?.header?.userRelationLabel.accessibilityId = .userHeaderExpandedRelationLabel
        headerContainer?.header?.buildTrustButton.accessibilityId = .userHeaderExpandedBuildTrustButton
        headerContainer?.header?.sellingButton.accessibilityId = .userSellingTab
        headerContainer?.header?.soldButton.accessibilityId = .userSoldTab
        headerContainer?.header?.favoritesButton.accessibilityId = .userFavoritesTab

        productListView.firstLoadView.accessibilityId = .userProductsFirstLoad
        productListView.collectionView.accessibilityId = .userProductsList
        productListView.errorView.accessibilityId = .userProductsError
    }

    private func setupMainView() {
        guard let patternImage = UIImage(named: "pattern_transparent") else { return }
        patternView.backgroundColor = UIColor(patternImage: patternImage)
    }

    private func setupHeader() {
        headerGestureRecognizer.addTarget(self, action: #selector(handleHeaderPan))
        view.addGestureRecognizer(headerGestureRecognizer)

        headerContainer.headerDelegate = self
    }

    private func setupNavigationBar() {
        navBarUserView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: UserViewController.navBarUserViewHeight))
        setNavBarTitleStyle(.custom(navBarUserView))
        navBarUserViewAlpha = 0

        let backIcon = UIImage(named: "navbar_back_white_shadow")
        setNavBarBackButton(backIcon)
    }

    private func setupProductListView() {
        productListView.headerDelegate = self
        productListViewBackgroundView.backgroundColor = UIColor.listBackgroundColor

        // Remove pull to refresh
        productListView.refreshControl?.removeFromSuperview()
        productListView.setErrorViewStyle(bgColor: nil, borderColor: nil, containerColor: nil)
        productListView.shouldScrollToTopOnFirstPageReload = false
        productListView.padding = UIEdgeInsets(top: UserViewController.productListViewTopMargin, left: 0, bottom: 0, right: 0)

        let top = abs(UserViewController.headerExpandedBottom + UserViewController.productListViewTopMargin)
        let contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottomInset, right: 0)
        productListView.collectionViewContentInset = contentInset
        productListView.collectionView.scrollIndicatorInsets.top = contentInset.top
        productListView.firstLoadPadding = contentInset
        productListView.errorPadding = contentInset
        productListView.scrollDelegate = self
    }

    func setupRatingAverage(_ ratingAverage: Float?) {
        let rating = ratingAverage ?? 0
        if rating > 0 {
            averageRatingContainerViewHeight.constant = UserViewController.ratingAverageContainerHeightVisible
            averageRatingView.setupRatingContainer(rating: rating)
            averageRatingView.superview?.layoutIfNeeded()
            averageRatingView.rounded = true
        } else {
            averageRatingContainerViewHeight.constant = 0
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        productListView.minimumContentHeight = productListView.collectionView.frame.height - UserViewController.headerCollapsedHeight - bottomInset

        averageRatingView.rounded = true
    }

    fileprivate func scrollDidChange(_ contentOffsetInsetY: CGFloat) {
        let minBottom = UserViewController.headerExpandedBottom
        let maxBottom = UserViewController.headerCollapsedBottom

        let bottom = min(maxBottom, contentOffsetInsetY - UserViewController.productListViewTopMargin)
        headerContainerBottom.constant = bottom

        let percentage = min(1, abs(bottom - maxBottom) / abs(maxBottom - minBottom))

        let height = UserViewController.headerCollapsedHeight + percentage * (UserViewController.headerExpandedHeight - UserViewController.headerCollapsedHeight)
        headerContainerHeight.constant = height

        // header expands more than 100% to hide the avatar when pulling
        let headerPercentage = abs(bottom - maxBottom) / abs(maxBottom - minBottom)
        headerExpandedPercentage.value = headerPercentage

        // update top on error/first load views
        let maxTop = abs(UserViewController.headerExpandedBottom + UserViewController.productListViewTopMargin)
        let minTop = abs(UserViewController.headerCollapsedBottom)
        let top = minTop + percentage * (maxTop - minTop)
        let firstLoadPadding = UIEdgeInsets(top: top,
                                            left: productListView.firstLoadPadding.left,
                                            bottom: productListView.firstLoadPadding.bottom,
                                            right: productListView.firstLoadPadding.right)
        productListView.firstLoadPadding = firstLoadPadding
        let errorPadding = UIEdgeInsets(top: top,
                                        left: productListView.firstLoadPadding.left,
                                        bottom: productListView.firstLoadPadding.bottom,
                                        right: productListView.firstLoadPadding.right)
        productListView.errorPadding = errorPadding
    }

    dynamic private func handleHeaderPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        gestureRecognizer.setTranslation(CGPoint.zero, in: view)

        let mininum: CGFloat = -(UserViewController.headerCollapsedHeight + view.frame.width)
        let maximum: CGFloat = -UserViewController.headerCollapsedHeight
        let y = min(maximum, max(mininum, productListView.collectionView.contentOffset.y  - translation.y))

        productListView.collectionView.contentOffset.y = y

        switch gestureRecognizer.state {
        case .began:
            headerRecognizerDragging.value = true
        case .ended, .cancelled:
            headerRecognizerDragging.value = false
        default:
            break
        }
    }

    fileprivate func scrollToTopWithExpandedState(_ expanded: Bool, animated: Bool) {
        let mininum: CGFloat = UserViewController.headerExpandedBottom + UserViewController.productListViewTopMargin
        let maximum: CGFloat = -UserViewController.headerCollapsedHeight
        let y = expanded ? mininum : maximum
        let contentOffset = CGPoint(x: 0, y: y)
        productListView.collectionView.setContentOffset(contentOffset, animated: animated)
    }
}


// MARK: - Rx

extension UserViewController {
    fileprivate func setupRxBindings() {
        setupBackgroundRxBindings()
        setupUserBgViewRxBindings()
        setupNavBarRxBindings()
        setupHeaderRxBindings()
        setupProductListViewRxBindings()
        setupPermissionsRx()
        setupUserLabelsContainerRx()
    }

    private func setupBackgroundRxBindings() {
        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.view.backgroundColor = bgColor
        }.addDisposableTo(disposeBag)
    }

    private func setupUserBgViewRxBindings() {
        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.userBgTintView.backgroundColor = bgColor
        }.addDisposableTo(disposeBag)

        let userAvatarPresent: Observable<Bool> = viewModel.userAvatarURL.asObservable().map { url in
            guard let url = url, let urlString = url.absoluteString else { return false }
            return !urlString.isEmpty
        }
        // Pattern overlay is hidden if there's no avatar and user background view is shown if so
        userAvatarPresent.bindTo(patternView.rx.isHidden).addDisposableTo(disposeBag)
        userAvatarPresent.map{ !$0 }.bindTo(userBgView.rx.isHidden).addDisposableTo(disposeBag)

        // Load avatar image
        viewModel.userAvatarURL.asObservable().subscribeNext { [weak self] url in
            guard let url = url else { return }
            self?.userBgImageView.lg_setImageWithURL(url)
        }.addDisposableTo(disposeBag)
    }

    private func setupNavBarRxBindings() {
        Observable.combineLatest(
            viewModel.userName.asObservable(),
            viewModel.userLocation.asObservable(),
            viewModel.userAvatarURL.asObservable(),
            viewModel.userAvatarPlaceholder.asObservable()) { $0 }
        .subscribeNext { [weak self] (userName, userLocation, avatar, placeholder) in
            guard let navBarUserView = self?.navBarUserView else { return }
            navBarUserView.setupWith(userAvatar: avatar, placeholder: placeholder, userName: userName,
                subtitle: userLocation)
        }.addDisposableTo(disposeBag)

        viewModel.navBarButtons.asObservable().subscribeNext { [weak self] navBarButtons in
            guard let strongSelf = self else { return }

            var buttons = [UIButton]()
            navBarButtons.forEach { navBarButton in
                let button = UIButton(type: .system)
                button.setImage(navBarButton.image, for: .normal)
                button.rx.tap.bindNext { _ in
                    navBarButton.action()
                }.addDisposableTo(strongSelf.disposeBag)
                buttons.append(button)
            }
            strongSelf.setNavigationBarRightButtons(buttons)
        }.addDisposableTo(disposeBag)
    }

    private func setupHeaderRxBindings() {
        // Name, location, avatar & bg
        viewModel.userName.asObservable().bindTo(userNameLabel.rx_optionalText).addDisposableTo(disposeBag)
        viewModel.userLocation.asObservable().bindTo(userLocationLabel.rx_optionalText).addDisposableTo(disposeBag)

        Observable.combineLatest(viewModel.userAvatarURL.asObservable(),
            viewModel.userAvatarPlaceholder.asObservable()) { ($0, $1) }
            .subscribeNext { [weak self] (avatar, placeholder) in
                self?.headerContainer.header?.setAvatar(avatar, placeholderImage: placeholder)
        }.addDisposableTo(disposeBag)

        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.headerContainer.header?.selectedColor = bgColor
        }.addDisposableTo(disposeBag)

        // Ratings
        viewModel.userRatingAverage.asObservable().subscribeNext { [weak self] userRatingAverage in
            self?.setupRatingAverage(userRatingAverage)
        }.addDisposableTo(disposeBag)
        viewModel.userRatingAverage.asObservable().bindTo(navBarUserView.userRatings).addDisposableTo(disposeBag)

        viewModel.userRatingCount.asObservable().subscribeNext { [weak self] userRatingCount in
            self?.headerContainer.header?.setRatingCount(userRatingCount)
        }.addDisposableTo(disposeBag)

        // User relation
        viewModel.userRelationText.asObservable().subscribeNext { [weak self] userRelationText in
            self?.headerContainer.header?.setUserRelationText(userRelationText)
        }.addDisposableTo(disposeBag)

        // Accounts
        viewModel.userAccounts.asObservable().subscribeNext { [weak self] accounts in
            self?.headerContainer.header?.accounts = accounts
        }.addDisposableTo(disposeBag)

        // Header mode
        viewModel.headerMode.asObservable().subscribeNext { [weak self] mode in
            self?.headerContainer.header?.mode = mode
        }.addDisposableTo(disposeBag)

        // Header collapse notify percentage
        headerExpandedPercentage.asObservable().map { percentage -> CGFloat in
            let max = UserViewController.userBgTintViewHeaderCollapsedAlpha
            let min = UserViewController.userBgTintViewHeaderExpandedAlpha
            return min + 1 - (percentage * max)
        }.bindTo(userBgTintView.rx.alpha).addDisposableTo(disposeBag)

        headerExpandedPercentage.asObservable().map { percentage -> CGFloat in
            let collapsedAlpha = UserViewController.userEffectViewHeaderCollapsedAlpha
            let expandedAlpha = UserViewController.userEffectViewHeaderExpandedAlpha
            var alpha = collapsedAlpha + 1 - (percentage * expandedAlpha)    // between collapsed & expanded

            // If exceeding expanded, then decrease alpha
            if percentage > 1 {
                alpha += (percentage - 1) * (UserViewController.userEffectViewHeaderExpandedDoubleAlpha - expandedAlpha)
            }
            return alpha
        }.bindTo(userBgEffectView.rx.alpha).addDisposableTo(disposeBag)

        // Header elements alpha selection
        headerExpandedPercentage.asObservable()
            .distinctUntilChanged().subscribeNext { [weak self] expandedPerc in
                if expandedPerc > 1 {
                    self?.navBarUserViewAlpha = 0
                    let headerAlphas = 1 - expandedPerc.percentageBetween(start: 1.0,
                        end: UserViewController.userLabelsAndHeaderMaxThreshold)
                    self?.headerContainer.header?.itemsAlpha = headerAlphas
                    self?.userLabelsContainer.alpha = headerAlphas
                } else {
                    self?.navBarUserViewAlpha = 1 - expandedPerc.percentageTo(UserViewController.navbarHeaderMaxThresold)
                    self?.headerContainer.header?.itemsAlpha =
                        expandedPerc.percentageBetween(start: UserViewController.headerMinThreshold, end: 1.0)
                    self?.userLabelsContainer.alpha =
                        expandedPerc.percentageBetween(start: UserViewController.userLabelsMinThreshold, end: 1.0)
                }
            }.addDisposableTo(disposeBag)

        // Header sticky to expanded/collapsed
        let listViewDragging = productListView.isDragging.asObservable().distinctUntilChanged()
        let recognizerDragging = headerRecognizerDragging.asObservable().distinctUntilChanged()
        let dragging = Observable.combineLatest(listViewDragging, recognizerDragging){ $0 || $1 }.distinctUntilChanged()

        dragging.filter { !$0 }
            .map { [weak self] _ in
                return self?.headerExpandedPercentage.value > 0.5
            }
            .subscribeNext { [weak self] expand in
                // If should expand should always expand, but when collapsed do not f'up the user current scroll
                guard expand || !expand && self?.headerExpandedPercentage.value > 0 else { return }

                self?.scrollToTopWithExpandedState(expand, animated: true)
            }
            .addDisposableTo(disposeBag)

        // Tab switch
        headerContainer.header?.tab.asObservable().bindTo(viewModel.tab).addDisposableTo(disposeBag)
    }
    
    private func setupUserLabelsContainerRx() {
        viewModel.navBarButtons.asObservable().bindNext { [weak self] buttons in
            let margin = buttons.count > 1 ? UserViewController.userLabelsContainerMarginLong : UserViewController.userLabelsContainerMarginShort
            self?.userLabelsSideMargin.forEach { $0.constant = margin }
            }.addDisposableTo(disposeBag)
    }

    private func setupProductListViewRxBindings() {
        viewModel.productListViewModel.asObservable().subscribeNext { [weak self] viewModel in
            guard let strongSelf = self else { return }
            strongSelf.productListView.switchViewModel(viewModel)
            strongSelf.productListView.refreshDataView()
            let expanded = strongSelf.headerExpandedPercentage.value > 0
            strongSelf.scrollToTopWithExpandedState(expanded, animated: false)
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - ScrollableToTop

extension UserViewController: ScrollableToTop {
    func scrollToTop() {
        productListView.scrollToTop(true)
    }
}


// MARK: - ProductListViewHeaderDelegate

extension UserViewController: ProductListViewHeaderDelegate, PushPermissionsHeaderDelegate {

    func setupPermissionsRx() {
        viewModel.pushPermissionsDisabledWarning.asObservable().filter {$0 != nil} .bindNext { [weak self] _ in
            self?.productListView.refreshDataView()
        }.addDisposableTo(disposeBag)
    }

    func totalHeaderHeight() -> CGFloat {
        guard showHeader else { return 0 }
        return PushPermissionsHeader.viewHeight
    }

    func setupViewsInHeader(_ header: ListHeaderContainer) {
        if showHeader {
            let pushHeader = PushPermissionsHeader()
            pushHeader.delegate = self
            header.addHeader(pushHeader, height: PushPermissionsHeader.viewHeight)
        } else {
            header.clear()
        }
    }

    func pushPermissionHeaderPressed() {
        viewModel.pushPermissionsWarningPressed()
    }

    private var showHeader: Bool {
        return viewModel.pushPermissionsDisabledWarning.value ?? false
    }
}
