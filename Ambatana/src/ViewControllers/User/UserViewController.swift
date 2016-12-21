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
    private static let navBarUserViewHeight: CGFloat = 36
    private static let userBgViewDefaultHeight: CGFloat = headerExpandedHeight

    private static let productListViewTopMargin: CGFloat = 64

    private static let headerExpandedBottom: CGFloat = -(headerExpandedHeight+userBgViewDefaultHeight)
    private static let headerExpandedHeight: CGFloat = 150

    private static let headerCollapsedBottom: CGFloat = -(20+44+UserViewController.headerCollapsedHeight) // 20 status bar + 44 fake nav bar + 44 header buttons
    private static let headerCollapsedHeight: CGFloat = 44

    private static let navbarHeaderMaxThresold: CGFloat = 0.5
    private static let userLabelsMinThreshold: CGFloat = 0.5
    private static let headerMinThreshold: CGFloat = 0.7
    private static let userLabelsAndHeaderMaxThreshold: CGFloat = 1.5

    private static let userBgTintViewHeaderExpandedAlpha: CGFloat = 0.54
    private static let userBgTintViewHeaderCollapsedAlpha: CGFloat = 1.0

    private static let userEffectViewHeaderExpandedDoubleAlpha: CGFloat = 0.0
    private static let userEffectViewHeaderExpandedAlpha: CGFloat = 1.0
    private static let userEffectViewHeaderCollapsedAlpha: CGFloat = 1.0

    private static let ratingAverageContainerHeightVisible: CGFloat = 30
    
    private static let userLabelsContainerMarginLong: CGFloat = 90
    private static let userLabelsContainerMarginShort: CGFloat = 50

    private var navBarUserView: UserView
    private var navBarUserViewAlpha: CGFloat = 0.0 {
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
    private let headerGestureRecognizer: UIPanGestureRecognizer
    private let headerRecognizerDragging = Variable<Bool>(false)
    
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

    private var bottomInset: CGFloat = 0
    private let cellDrawer: ProductCellDrawer
    private var viewModel: UserViewModel
    private let socialSharer: SocialSharer

    private let headerExpandedPercentage = Variable<CGFloat>(1)
    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

    init(viewModel: UserViewModel, hidesBottomBarWhenPushed: Bool = false) {
        let size = CGSize(width: CGFloat.max, height: UserViewController.navBarUserViewHeight)
        self.navBarUserView = UserView.userView(.CompactBorder(size: size))
        self.headerGestureRecognizer = UIPanGestureRecognizer()
        self.viewModel = viewModel
        let socialSharer = SocialSharer()
        socialSharer.delegate = viewModel
        self.socialSharer = socialSharer
        self.cellDrawer = ProductCellDrawer()
        self.disposeBag = DisposeBag()
        super.init(viewModel: viewModel, nibName: "UserViewController", statusBarStyle: .LightContent,
                   navBarBackgroundStyle: .Transparent(substyle: .Light))

        self.viewModel.delegate = self
        self.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        self.automaticallyAdjustsScrollViewInsets = false
        self.hasTabBar = viewModel.isMyProfile
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let tabBarCtl = tabBarController {
            bottomInset = tabBarCtl.tabBar.hidden ? 0 : tabBarCtl.tabBar.frame.height
        }
        else {
            bottomInset = 0
        }

        setupUI()
        setupAccessibilityIds()
        setupRxBindings()
    }

    override func viewWillAppearFromBackground(fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        view.backgroundColor = viewModel.backgroundColor.value

        // UINavigationBar's title alpha gets resetted on view appear, does not allow initial 0.0 value
        let currentAlpha: CGFloat = navBarUserViewAlpha
        navBarUserView.hidden = true
        delay(0.01) { [weak self] in
            self?.navBarUserView.alpha = currentAlpha
            self?.navBarUserView.hidden = false
        }
    }

    override func viewWillDisappearToBackground(toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)

        // Animating to clear background color as it glitches next screen translucent navBar
        // http://stackoverflow.com/questions/28245061/why-does-setting-hidesbottombarwhenpushed-to-yes-with-a-translucent-navigation
        UIView.animateWithDuration(0.3) { [weak self] in
            self?.view.backgroundColor = UIColor.whiteColor()
        }
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
    func productListView(productListView: ProductListView, didScrollDown scrollDown: Bool) {
    }

    func productListView(productListView: ProductListView, didScrollWithContentOffsetY contentOffsetY: CGFloat) {
        scrollDidChange(contentOffsetY)
    }
}


// MARK: - UserViewModelDelegate

extension UserViewController: UserViewModelDelegate {
    func vmOpenReportUser(reportUserVM: ReportUsersViewModel) {
        let vc = ReportUsersViewController(viewModel: reportUserVM)
        navigationController?.pushViewController(vc, animated: true)
    }

    func vmOpenHome() {
        guard let tabBarCtl = tabBarController as? TabBarController else { return }
        tabBarCtl.switchToTab(.Home)
    }
    
    func vmShowUserActionSheet(cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: navigationItem.rightBarButtonItem)
    }

    func vmShowNativeShare(socialMessage: SocialMessage) {
        socialSharer.share(socialMessage, shareType: .Native, viewController: self, barButtonItem: navigationItem.rightBarButtonItems?.first)
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
    private func setupUI() {
        setupMainView()
        setupHeader()
        setupNavigationBar()
        setupProductListView()
    }

    private func setupAccessibilityIds() {
        navBarUserView.titleLabel.accessibilityId = .UserHeaderCollapsedNameLabel
        navBarUserView.subtitleLabel.accessibilityId = .UserHeaderCollapsedLocationLabel
        userNameLabel.accessibilityId = .UserHeaderExpandedNameLabel
        userLocationLabel.accessibilityId = .UserHeaderExpandedLocationLabel

        headerContainer?.header?.avatarButton.accessibilityId = .UserHeaderExpandedAvatarButton
        headerContainer?.header?.ratingsButton.accessibilityId = .UserHeaderExpandedRatingsButton
        headerContainer?.header?.userRelationLabel.accessibilityId = .UserHeaderExpandedRelationLabel
        headerContainer?.header?.buildTrustButton.accessibilityId = .UserHeaderExpandedBuildTrustButton
        headerContainer?.header?.sellingButton.accessibilityId = .UserSellingTab
        headerContainer?.header?.soldButton.accessibilityId = .UserSoldTab
        headerContainer?.header?.favoritesButton.accessibilityId = .UserFavoritesTab

        productListView.firstLoadView.accessibilityId = .UserProductsFirstLoad
        productListView.collectionView.accessibilityId = .UserProductsList
        productListView.errorView.accessibilityId = .UserProductsError
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
        navBarUserView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat.max, height: UserViewController.navBarUserViewHeight))
        setNavBarTitleStyle(.Custom(navBarUserView))
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

    func setupRatingAverage(ratingAverage: Float?) {
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

    private func scrollDidChange(contentOffsetInsetY: CGFloat) {
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

    dynamic private func handleHeaderPan(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translationInView(view)
        gestureRecognizer.setTranslation(CGPoint.zero, inView: view)

        let mininum: CGFloat = -(UserViewController.headerCollapsedHeight + view.frame.width)
        let maximum: CGFloat = -UserViewController.headerCollapsedHeight
        let y = min(maximum, max(mininum, productListView.collectionView.contentOffset.y  - translation.y))

        productListView.collectionView.contentOffset.y = y

        switch gestureRecognizer.state {
        case .Began:
            headerRecognizerDragging.value = true
        case .Ended, .Cancelled:
            headerRecognizerDragging.value = false
        default:
            break
        }
    }

    private func scrollToTopWithExpandedState(expanded: Bool, animated: Bool) {
        let mininum: CGFloat = UserViewController.headerExpandedBottom + UserViewController.productListViewTopMargin
        let maximum: CGFloat = -UserViewController.headerCollapsedHeight
        let y = expanded ? mininum : maximum
        let contentOffset = CGPoint(x: 0, y: y)
        productListView.collectionView.setContentOffset(contentOffset, animated: animated)
    }
}


// MARK: - Rx

extension UserViewController {
    private func setupRxBindings() {
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
            guard let url = url, urlString = url.absoluteString else { return false }
            return !urlString.isEmpty
        }
        // Pattern overlay is hidden if there's no avatar and user background view is shown if so
        userAvatarPresent.bindTo(patternView.rx_hidden).addDisposableTo(disposeBag)
        userAvatarPresent.map{ !$0 }.bindTo(userBgView.rx_hidden).addDisposableTo(disposeBag)

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
                let button = UIButton(type: .System)
                button.setImage(navBarButton.image, forState: .Normal)
                button.rx_tap.bindNext { _ in
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
        }.bindTo(userBgTintView.rx_alpha).addDisposableTo(disposeBag)

        headerExpandedPercentage.asObservable().map { percentage -> CGFloat in
            let collapsedAlpha = UserViewController.userEffectViewHeaderCollapsedAlpha
            let expandedAlpha = UserViewController.userEffectViewHeaderExpandedAlpha
            var alpha = collapsedAlpha + 1 - (percentage * expandedAlpha)    // between collapsed & expanded

            // If exceeding expanded, then decrease alpha
            if percentage > 1 {
                alpha += (percentage - 1) * (UserViewController.userEffectViewHeaderExpandedDoubleAlpha - expandedAlpha)
            }
            return alpha
        }.bindTo(userBgEffectView.rx_alpha).addDisposableTo(disposeBag)

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

    func setupViewsInHeader(header: ListHeaderContainer) {
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
