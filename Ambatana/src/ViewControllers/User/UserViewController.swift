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
    fileprivate static let userLabelsVerticalMargin: CGFloat = 10
    fileprivate var userBgViewDefaultHeight: CGFloat {
        return headerExpandedHeight
    }
    
    fileprivate var listingListViewTopMargin: CGFloat {
        return navigationBarHeight + statusBarHeight
    }

    fileprivate var headerExpandedBottom: CGFloat {
        return -(headerExpandedHeight+userBgViewDefaultHeight)
    }
    fileprivate var headerExpandedHeight: CGFloat {
        return navigationBarHeight + statusBarHeight + headerExpandedPadding
    }
    fileprivate let headerExpandedPadding: CGFloat = 86

    fileprivate var headerCollapsedBottom: CGFloat {
        if #available(iOS 11, *) {
            return -(view.safeAreaInsets.top + headerCollapsedHeight)
        } else {
            return -(20 + 44 + headerCollapsedHeight) // 20 status bar + 44 fake nav bar + 44 header buttons
        }
    }
    fileprivate let headerCollapsedHeight: CGFloat = 44
    
    fileprivate var dummyUserViewHeight: CGFloat {
        return headerContainer.header.dummyUserDisclaimerContainerView?.height ?? 0
    }

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
    
    @IBOutlet weak var listingListViewBackgroundView: UIView!
    @IBOutlet weak var listingListView: ListingListView!
    
    @IBOutlet weak var userLabelsContainer: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var averageRatingContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var averageRatingView: UIView!
    @IBOutlet var userLabelsSideMargin: [NSLayoutConstraint]!
    @IBOutlet weak var userLabelsTopMargin: NSLayoutConstraint!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userBgImageView: UIImageView!
    @IBOutlet weak var userBgTintView: UIView!

    fileprivate let userBgTintViewAlpha = Variable<CGFloat>(0)
    fileprivate var bottomInset: CGFloat = 0
    fileprivate let cellDrawer: ListingCellDrawer
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
        self.cellDrawer = ListingCellDrawer()
        self.disposeBag = DisposeBag()
        
        super.init(viewModel: viewModel, nibName: "UserViewController", statusBarStyle: .lightContent,
                   navBarBackgroundStyle: .transparent(substyle: .light))
        
        self.viewModel.delegate = self
        self.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        self.automaticallyAdjustsScrollViewInsets = false
        self.hasTabBar = viewModel.isMyProfile
    }
    
    convenience init(viewModel: UserViewModel, hidesBottomBarWhenPushed: Bool = false) {
        let notificationsManager = LGNotificationsManager.sharedInstance
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
        userBgTintView.alpha = userBgTintViewAlpha.value

        userBgImageView.alpha = 1
    }

    override func viewWillDisappearToBackground(_ toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)
        
        updateNavBarForTransition(isHidden: true)
        
        // Animating to clear background color as it glitches next screen translucent navBar
        // http://stackoverflow.com/questions/28245061/why-does-setting-hidesbottombarwhenpushed-to-yes-with-a-translucent-navigation
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.view.backgroundColor = UIColor.white
            self?.userBgTintView.alpha = 0
            self?.userBgImageView.alpha = 0
            })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listingListView.minimumContentHeight = listingListView.collectionView.frame.height - headerCollapsedHeight
        
        averageRatingView.setRoundedCorners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateNavBarForTransition(isHidden: false)
    }

    override func viewDidFirstAppear(_ animated: Bool) {
        super.viewDidFirstAppear(animated)
        setupNavigationBar()
    }
    
    private func updateNavBarForTransition(isHidden: Bool) {
        if !isHidden && navBarUserViewAlpha == 0 {
            // UINavigationBar's title alpha gets resetted on view appear, does not allow initial 0.0 value
            let currentAlpha: CGFloat = navBarUserViewAlpha
            self.navBarUserView.alpha = currentAlpha
        }
        
        navBarUserView.isHidden = isHidden
    }
}


// MARK: - ListingsRefreshable

extension UserViewController: ListingsRefreshable {
    func listingsRefresh() {
        viewModel.refreshSelling()
    }
}


// MARK: - ListingListViewScrollDelegate

extension UserViewController: ListingListViewScrollDelegate {
    func listingListView(_ listingListView: ListingListView, didScrollDown scrollDown: Bool) {
    }

    func listingListView(_ listingListView: ListingListView, didScrollWithContentOffsetY contentOffsetY: CGFloat) {
        updateLayoutConstraints(contentOffsetY)
    }
}


// MARK: - UserViewModelDelegate

extension UserViewController: UserViewModelDelegate {
    func vmOpenReportUser(_ reportUserVM: ReportUsersViewModel) {
        let vc = ReportUsersViewController(viewModel: reportUserVM)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func vmShowUserActionSheet(_ cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: navigationItem.rightBarButtonItem)
    }

    func vmShowNativeShare(_ socialMessage: SocialMessage) {
        socialSharer.share(socialMessage,
                           shareType: .native(restricted: false),
                           viewController: self,
                           barButtonItem: navigationItem.rightBarButtonItems?.first)
    }
    
    func vmDiscardedProductShowOptions(actions: [UIAction]) {
        showActionSheet(LGLocalizedString.commonCancel, actions: actions)
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
        setupListingListView()
        setupConstraints()
    }

    fileprivate func setupAccessibilityIds() {
        navBarUserView.titleLabel.set(accessibilityId: .userHeaderCollapsedNameLabel)
        navBarUserView.subtitleLabel.set(accessibilityId: .userHeaderCollapsedLocationLabel)
        userNameLabel.set(accessibilityId: .userHeaderExpandedNameLabel)
        userLocationLabel.set(accessibilityId: .userHeaderExpandedLocationLabel)

        headerContainer?.header.avatarButton.set(accessibilityId: .userHeaderExpandedAvatarButton)
        headerContainer?.header.ratingsButton.set(accessibilityId: .userHeaderExpandedRatingsButton)
        headerContainer?.header.userRelationLabel.set(accessibilityId: .userHeaderExpandedRelationLabel)
        headerContainer?.header.buildTrustButton.set(accessibilityId: .userHeaderExpandedBuildTrustButton)
        headerContainer?.header.sellingButton.set(accessibilityId: .userSellingTab)
        headerContainer?.header.soldButton.set(accessibilityId: .userSoldTab)
        headerContainer?.header.favoritesButton.set(accessibilityId: .userFavoritesTab)

        listingListView.firstLoadView.set(accessibilityId: .userListingsFirstLoad)
        listingListView.collectionView.set(accessibilityId: .userListingsList)
        listingListView.errorView.set(accessibilityId: .userListingsError)
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

        let backIcon = UIImage(named: "navbar_back_white_shadow")
        setNavBarBackButton(backIcon)
    }

    private func setupListingListView() {
        listingListView.headerDelegate = self
        listingListViewBackgroundView.backgroundColor = UIColor.listBackgroundColor
    
        // Remove pull to refresh
        listingListView.refreshControl.removeFromSuperview()
        listingListView.setErrorViewStyle(bgColor: nil, borderColor: nil, containerColor: nil)
        listingListView.shouldScrollToTopOnFirstPageReload = false
        listingListView.padding = UIEdgeInsets(top: listingListViewTopMargin, left: 0, bottom: 0, right: 0)

        let top = abs(headerExpandedBottom + listingListViewTopMargin)
        let contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottomInset, right: 0)
        listingListView.collectionViewContentInset = contentInset
        listingListView.collectionView.scrollIndicatorInsets.top = contentInset.top
        listingListView.firstLoadPadding = contentInset
        listingListView.errorPadding = contentInset
        listingListView.scrollDelegate = self
    }
    
    private func setupConstraints() {
        userLabelsTopMargin.constant = statusBarHeight + UserViewController.userLabelsVerticalMargin
    }

    func setupRatingAverage(_ ratingAverage: Float?) {
        let rating = ratingAverage ?? 0
        if rating > 0 {
            averageRatingContainerViewHeight.constant = UserViewController.ratingAverageContainerHeightVisible
            averageRatingView.setupRatingContainer(rating: rating)
            averageRatingView.superview?.layoutIfNeeded()
            averageRatingView.setRoundedCorners()
        } else {
            averageRatingContainerViewHeight.constant = 0
        }
    }

    fileprivate func updateLayoutConstraints(_ contentOffsetInsetY: CGFloat) {
        let minBottom = headerExpandedBottom
        let maxBottom = headerCollapsedBottom

        let bottom = min(maxBottom, contentOffsetInsetY - listingListViewTopMargin)
        headerContainerBottom.constant = bottom - dummyUserViewHeight

        let percentage = min(1, abs(bottom - maxBottom) / abs(maxBottom - minBottom))

        let height = headerCollapsedHeight + percentage * (headerExpandedHeight - headerCollapsedHeight)
        headerContainerHeight.constant = height + dummyUserViewHeight

        // header expands more than 100% to hide the avatar when pulling
        let headerPercentage = abs(bottom - maxBottom) / abs(maxBottom - minBottom)
        headerExpandedPercentage.value = headerPercentage
        
        // update top on error/first load views
        let maxTop = abs(headerExpandedBottom + listingListViewTopMargin)
        let minTop = abs(headerCollapsedBottom)
        let top = minTop + dummyUserViewHeight + percentage * (maxTop - minTop)
        let firstLoadPadding = UIEdgeInsets(top: top,
                                            left: listingListView.firstLoadPadding.left,
                                            bottom: listingListView.firstLoadPadding.bottom,
                                            right: listingListView.firstLoadPadding.right)
        listingListView.firstLoadPadding = firstLoadPadding
        let errorPadding = UIEdgeInsets(top: top,
                                        left: listingListView.firstLoadPadding.left,
                                        bottom: listingListView.firstLoadPadding.bottom,
                                        right: listingListView.firstLoadPadding.right)
        listingListView.errorPadding = errorPadding
    }

    @objc private func handleHeaderPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        gestureRecognizer.setTranslation(CGPoint.zero, in: view)

        let mininum: CGFloat = -(headerCollapsedHeight + view.frame.width)
        let maximum: CGFloat = -headerCollapsedHeight
        let y = min(maximum, max(mininum, listingListView.collectionView.contentOffset.y  - translation.y))

        listingListView.collectionView.contentOffset.y = y

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
        let mininum: CGFloat = headerExpandedBottom + listingListViewTopMargin
        let maximum: CGFloat = -headerCollapsedHeight
        let y = expanded ? mininum : maximum
        let contentOffset = CGPoint(x: 0, y: y)
        listingListView.collectionView.setContentOffset(contentOffset, animated: animated)
    }
}


// MARK: - Rx

extension UserViewController {
    fileprivate func setupRxBindings() {
        setupBackgroundRxBindings()
        setupUserBgViewRxBindings()
        setupNavBarRxBindings()
        setupHeaderRxBindings()
        setupListingListViewRxBindings()
        setupPermissionsRx()
        setupUserLabelsContainerRx()
    }

    private func setupBackgroundRxBindings() {
        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.view.backgroundColor = bgColor
        }.disposed(by: disposeBag)
    }

    private func setupUserBgViewRxBindings() {
        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.userBgTintView.backgroundColor = bgColor
        }.disposed(by: disposeBag)

        let userAvatarPresent: Observable<Bool> = viewModel.userAvatarURL.asObservable().map { url in
            guard let urlString = url?.absoluteString else { return false }
            return !urlString.isEmpty
        }
        // Pattern overlay is hidden if there's no avatar and user background view is shown if so
        userAvatarPresent.bind(to: patternView.rx.isHidden).disposed(by: disposeBag)
        userAvatarPresent.map{ !$0 }.bind(to: userBgView.rx.isHidden).disposed(by: disposeBag)

        // Load avatar image
        viewModel.userAvatarURL.asObservable().subscribeNext { [weak self] url in
            guard let url = url else { return }
            self?.userBgImageView.lg_setImageWithURL(url)
        }.disposed(by: disposeBag)
    }

    private func setupNavBarRxBindings() {
        Observable.combineLatest(
            viewModel.userName.asObservable(),
            viewModel.userLocation.asObservable(),
            viewModel.userAvatarURL.asObservable(),
            viewModel.userAvatarPlaceholder.asObservable(),
            viewModel.userIsProfessional.asObservable()) { ($0, $1, $2, $3, $4) }
        .subscribeNext { [weak self] (userName, userLocation, avatar, placeholder, isPro) in
            guard let navBarUserView = self?.navBarUserView else { return }
            navBarUserView.setupWith(userAvatar: avatar, placeholder: placeholder, userName: userName,
                subtitle: userLocation, isProfessional: isPro)
        }.disposed(by: disposeBag)

        viewModel.navBarButtons.asObservable().subscribeNext { [weak self] navBarButtons in
            guard let strongSelf = self else { return }

            var buttons = [UIButton]()
            navBarButtons.forEach { navBarButton in
                let button = UIButton(type: .system)
                button.setImage(navBarButton.image, for: .normal)
                button.rx.tap.bind { _ in
                    navBarButton.action()
                }.disposed(by: strongSelf.disposeBag)
                buttons.append(button)
            }
            strongSelf.setNavigationBarRightButtons(buttons)
        }.disposed(by: disposeBag)
    }

    private func setupHeaderRxBindings() {
        // Name, location, avatar & bg
        viewModel.userName.asObservable().bind(to: userNameLabel.rx.text).disposed(by: disposeBag)
        viewModel.userLocation.asObservable().bind(to: userLocationLabel.rx.text).disposed(by: disposeBag)

        Observable.combineLatest(viewModel.userAvatarURL.asObservable(),
            viewModel.userAvatarPlaceholder.asObservable()) { ($0, $1) }
            .subscribeNext { [weak self] (avatar, placeholder) in
                self?.headerContainer.header.setAvatar(avatar, placeholderImage: placeholder)
        }.disposed(by: disposeBag)

        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.headerContainer.header.selectedColor = bgColor
        }.disposed(by: disposeBag)
        
        viewModel.userIsProfessional.asObservable().map{ !$0 }
            .bind(to: headerContainer.header.proTagImageView.rx.isHidden)
            .disposed(by: disposeBag)

        // Ratings
        viewModel.userRatingAverage.asObservable().subscribeNext { [weak self] userRatingAverage in
            self?.setupRatingAverage(userRatingAverage)
        }.disposed(by: disposeBag)
        viewModel.userRatingAverage.asObservable().bind(to: navBarUserView.userRatings).disposed(by: disposeBag)

        viewModel.userRatingCount.asObservable().subscribeNext { [weak self] userRatingCount in
            self?.headerContainer.header.setRatingCount(userRatingCount)
        }.disposed(by: disposeBag)

        // User relation
        viewModel.userRelationText.asObservable().subscribeNext { [weak self] userRelationText in
            self?.headerContainer.header.setUserRelationText(userRelationText)
        }.disposed(by: disposeBag)

        // Accounts
        viewModel.userAccounts.asObservable().subscribeNext { [weak self] accounts in
            self?.headerContainer.header.accounts = accounts
        }.disposed(by: disposeBag)

        // Header mode
        viewModel.headerMode.asObservable().subscribeNext { [weak self] mode in
            self?.headerContainer.header.mode = mode
        }.disposed(by: disposeBag)

        // Header collapse notify percentage
        headerExpandedPercentage.asObservable().map { percentage -> CGFloat in
            let max = UserViewController.userBgTintViewHeaderCollapsedAlpha
            let min = UserViewController.userBgTintViewHeaderExpandedAlpha
            return min + 1 - (percentage * max)
        }.bind(to: userBgTintViewAlpha).disposed(by: disposeBag)
        
        userBgTintViewAlpha.asObservable().bind(to: userBgTintView.rx.alpha).disposed(by: disposeBag)

        headerExpandedPercentage.asObservable().map { percentage -> CGFloat in
            let collapsedAlpha = UserViewController.userEffectViewHeaderCollapsedAlpha
            let expandedAlpha = UserViewController.userEffectViewHeaderExpandedAlpha
            var alpha = collapsedAlpha + 1 - (percentage * expandedAlpha)    // between collapsed & expanded

            // If exceeding expanded, then decrease alpha
            if percentage > 1 {
                alpha += (percentage - 1) * (UserViewController.userEffectViewHeaderExpandedDoubleAlpha - expandedAlpha)
            }
            return alpha
        }.bind(to: userBgEffectView.rx.alpha).disposed(by: disposeBag)

        // Header elements alpha selection
        headerExpandedPercentage.asObservable()
            .distinctUntilChanged().subscribeNext { [weak self] expandedPerc in
                if expandedPerc > 1 {
                    self?.navBarUserViewAlpha = 0
                    let headerAlphas = 1 - expandedPerc.percentageBetween(start: 1.0,
                        end: UserViewController.userLabelsAndHeaderMaxThreshold)
                    self?.headerContainer.header.itemsAlpha = headerAlphas
                    self?.userLabelsContainer.alpha = headerAlphas
                } else {
                    self?.navBarUserViewAlpha = 1 - expandedPerc.percentageTo(UserViewController.navbarHeaderMaxThresold)
                    self?.headerContainer.header.itemsAlpha =
                        expandedPerc.percentageBetween(start: UserViewController.headerMinThreshold, end: 1.0)
                    self?.userLabelsContainer.alpha =
                        expandedPerc.percentageBetween(start: UserViewController.userLabelsMinThreshold, end: 1.0)
                }
            }.disposed(by: disposeBag)

        // Header sticky to expanded/collapsed
        let listViewDragging = listingListView.isDragging.asObservable().distinctUntilChanged()
        let recognizerDragging = headerRecognizerDragging.asObservable().distinctUntilChanged()
        let dragging = Observable.combineLatest(listViewDragging, recognizerDragging){ $0 || $1 }.distinctUntilChanged()

        dragging.filter { !$0 }
            .map { [weak self] _ -> Bool in
                guard let strongSelf = self else { return false }
                return strongSelf.headerExpandedPercentage.value > CGFloat(0.5)
            }
            .subscribeNext { [weak self] expand in
                guard let strongSelf = self else { return }
                // If should expand should always expand, but when collapsed do not f'up the user current scroll
                guard expand || !expand && strongSelf.headerExpandedPercentage.value > 0 else { return }
                self?.scrollToTopWithExpandedState(expand, animated: true)
            }
            .disposed(by: disposeBag)

        // Tab switch
        headerContainer.header.tab.asObservable().bind(to: viewModel.tab).disposed(by: disposeBag)
        
        // Dummy users
        if viewModel.areDummyUsersEnabled {
            Observable.combineLatest(
                viewModel.userName.asObservable(),
                viewModel.userIsDummy.asObservable()) { ($0, $1) }
                .subscribeNext { [weak self] (userName, userIsDummy) in
                    guard let userName = userName else { return }
                    let infoText = LGLocalizedString.profileDummyUserInfo(userName)
                    self?.headerContainer.header.setupDummyView(isDummy: userIsDummy, infoText: infoText)
                    if let contentOffsetY = self?.listingListView.collectionView.contentOffset.y {
                        self?.updateLayoutConstraints(contentOffsetY)
                    }
            }.disposed(by: disposeBag)
        }
    }
    
    private func setupUserLabelsContainerRx() {
        viewModel.navBarButtons.asObservable().bind { [weak self] buttons in
            let margin = buttons.count > 1 ? UserViewController.userLabelsContainerMarginLong : UserViewController.userLabelsContainerMarginShort
            self?.userLabelsSideMargin.forEach { $0.constant = margin }
            }.disposed(by: disposeBag)
    }

    private func setupListingListViewRxBindings() {
        viewModel.listingListViewModel.asObservable().subscribeNext { [weak self] viewModel in
            guard let strongSelf = self else { return }
            strongSelf.listingListView.switchViewModel(viewModel)
            strongSelf.listingListView.refreshDataView()
            let expanded = strongSelf.headerExpandedPercentage.value > 0
            strongSelf.scrollToTopWithExpandedState(expanded, animated: false)
        }.disposed(by: disposeBag)
    }
}


// MARK: - ScrollableToTop

extension UserViewController: ScrollableToTop {
    func scrollToTop() {
        listingListView?.scrollToTop(true)
    }
}


// MARK: - ListingListViewHeaderDelegate, PushPermissionsHeaderDelegate, MostSearchedItemsUserHeaderDelegate

extension UserViewController: ListingListViewHeaderDelegate, PushPermissionsHeaderDelegate, MostSearchedItemsUserHeaderDelegate {

    func setupPermissionsRx() {
        viewModel.pushPermissionsDisabledWarning.asObservable().filter {$0 != nil} .bind { [weak self] _ in
            self?.listingListView.refreshDataView()
        }.disposed(by: disposeBag)
    }

    func totalHeaderHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        if showPushPermissionsHeader {
            totalHeight += PushPermissionsHeader.viewHeight
        }
        if showMostSearchedItemsHeader {
            totalHeight += MostSearchedItemsUserHeader.viewHeight
        }
        return totalHeight
    }

    func setupViewsIn(header: ListHeaderContainer) {
        header.clear()
        if showPushPermissionsHeader {
            let pushHeader = PushPermissionsHeader()
            pushHeader.tag = 0
            pushHeader.delegate = self
            header.addHeader(pushHeader, height: PushPermissionsHeader.viewHeight)
        }
        if showMostSearchedItemsHeader {
            let mostSearchedItemsHeader = MostSearchedItemsUserHeader()
            mostSearchedItemsHeader.tag = 1
            mostSearchedItemsHeader.delegate = self
            header.addHeader(mostSearchedItemsHeader, height: MostSearchedItemsUserHeader.viewHeight)
        }
    }

    func pushPermissionHeaderPressed() {
        viewModel.pushPermissionsWarningPressed()
    }
    
    func didTapMostSearchedItemsHeader() {
        viewModel.openMostSearchedItems()
    }

    private var showPushPermissionsHeader: Bool {
        return viewModel.pushPermissionsDisabledWarning.value ?? false
    }
    private var showMostSearchedItemsHeader: Bool {
        return viewModel.isMostSearchedItemsEnabled && viewModel.tab.value == .selling
    }
}
