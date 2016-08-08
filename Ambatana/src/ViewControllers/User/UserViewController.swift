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

    private static let expandedPercentageUserInfoSwitch: CGFloat = 0.85
    private static let expandedPercentageUserInfoDisappear: CGFloat = 1.2

    private static let userBgTintViewHeaderExpandedAlpha: CGFloat = 0.54
    private static let userBgTintViewHeaderCollapsedAlpha: CGFloat = 1.0

    private static let userEffectViewHeaderExpandedDoubleAlpha: CGFloat = 0.0
    private static let userEffectViewHeaderExpandedAlpha: CGFloat = 1.0
    private static let userEffectViewHeaderCollapsedAlpha: CGFloat = 1.0

    private static let ratingAverageContainerHeightVisible: CGFloat = 30


    private var navBarUserView: UserView?
    private var navBarUserViewAlphaOnDisappear: CGFloat = 0.0

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
    @IBOutlet var averageRatingImageViews: [UIImageView]!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userBgImageView: UIImageView!
    @IBOutlet weak var userBgTintView: UIView!

    private var bottomInset: CGFloat = 0
    private let cellDrawer: ProductCellDrawer
    private var viewModel: UserViewModel

    private let headerExpandedPercentage = Variable<CGFloat>(1)
    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

    init(viewModel: UserViewModel, hidesBottomBarWhenPushed: Bool = false) {
        let size = CGSize(width: CGFloat.max, height: UserViewController.navBarUserViewHeight)
        self.navBarUserView = UserView.userView(.CompactBorder(size: size))
        self.headerGestureRecognizer = UIPanGestureRecognizer()
        self.viewModel = viewModel
        self.cellDrawer = ProductCellDrawer()
        self.disposeBag = DisposeBag()
        super.init(viewModel: viewModel, nibName: "UserViewController", statusBarStyle: .LightContent,
                   navBarBackgroundStyle: .Transparent)

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
        setupRxBindings()
    }

    override func viewWillAppearFromBackground(fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)

        // UINavigationBar's title alpha gets resetted on view appear, does not allow initial 0.0 value
        if let navBarUserView = navBarUserView {
            let currentAlpha: CGFloat = navBarUserViewAlphaOnDisappear
            navBarUserView.hidden = true
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))),
                dispatch_get_main_queue()) {
                    navBarUserView.alpha = currentAlpha
                    navBarUserView.hidden = false
            }
        }
    }

    override func viewWillDisappearToBackground(toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)
        if let navBarUserView = navBarUserView {
            navBarUserViewAlphaOnDisappear = navBarUserView.alpha
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
    func vmOpenSettings(settingsVC: SettingsViewController) {
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    func vmOpenReportUser(reportUserVM: ReportUsersViewModel) {
        let vc = ReportUsersViewController(viewModel: reportUserVM)
        navigationController?.pushViewController(vc, animated: true)
    }

    func vmOpenVerifyAccount(verifyVM: VerifyAccountViewModel) {
        let presenter = tabBarController ?? navigationController
        let vc = VerifyAccountViewController(viewModel: verifyVM)
        presenter?.presentViewController(vc, animated: true, completion: nil)
    }

    func vmOpenHome() {
        guard let tabBarCtl = tabBarController as? TabBarController else { return }
        tabBarCtl.switchToTab(.Home)
    }

    func vmOpenRatingList(ratingListVM: UserRatingListViewModel) {
        let vc = UserRatingListViewController(viewModel: ratingListVM)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func vmShowUserActionSheet(cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: navigationItem.rightBarButtonItem)
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

    func facebookAccountAction() {
        viewModel.facebookButtonPressed()
    }

    func googleAccountAction() {
        viewModel.googleButtonPressed()
    }

    func emailAccountAction() {
        viewModel.emailButtonPressed()
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
        if let navBarUserView = navBarUserView {
            navBarUserView.alpha = 0
            navBarUserView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat.max, height: UserViewController.navBarUserViewHeight))
            setNavBarTitleStyle(.Custom(navBarUserView))
        }

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

            let full = UIImage(named: "ic_star_avg_full")
            let half = UIImage(named: "ic_star_avg_half")
            let empty = UIImage(named: "ic_star_avg_empty")
            averageRatingImageViews.forEach { imageView in
                let tag = Float(imageView.tag)
                let diff = tag - rating

                if diff <= 0 {
                    imageView.image = full
                } else if diff <= 0.5 {
                    imageView.image = half
                } else {
                    imageView.image = empty
                }
            }
        } else {
            averageRatingContainerViewHeight.constant = 0
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        productListView.minimumContentHeight = productListView.collectionView.frame.height - UserViewController.headerCollapsedHeight - bottomInset

        let height = averageRatingView.bounds.height
        averageRatingView.layer.cornerRadius = height / 2
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

        // Pattern overlay is hidden if there's no avatarand user background view is shown if so
        let userAvatar = viewModel.userAvatarURL.asObservable()
        userAvatar.map { url in
            guard let url = url else { return false }
            return !url.absoluteString.isEmpty
        }.bindTo(patternView.rx_hidden).addDisposableTo(disposeBag)

        userAvatar.map { url in
            guard let url = url else { return true }
            return url.absoluteString.isEmpty
        }.bindTo(userBgView.rx_hidden).addDisposableTo(disposeBag)

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

        // Header collapse switch
        headerExpandedPercentage.asObservable().map { $0 <= UserViewController.expandedPercentageUserInfoSwitch }
            .distinctUntilChanged().subscribeNext { [weak self] collapsed in
                self?.headerContainer.header?.collapsed = collapsed

                UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseIn, .BeginFromCurrentState], animations: {
                    let topAlpha: CGFloat = collapsed ? 1 : 0
                    let bottomAlpha: CGFloat = collapsed ? 0 : 1
                    self?.navBarUserView?.alpha = topAlpha
                    self?.userLabelsContainer.alpha = bottomAlpha
                    }, completion: nil)
        }.addDisposableTo(disposeBag)

        // Header disappear
        headerExpandedPercentage.asObservable().map { $0 >= UserViewController.expandedPercentageUserInfoDisappear }
            .distinctUntilChanged().subscribeNext { [weak self] hidden in
                self?.headerContainer.header?.collapsed = hidden

                UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseIn, .BeginFromCurrentState], animations: {
                    self?.userLabelsContainer.alpha = hidden ? 0 : 1
                }, completion: nil)
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

extension UserViewController: ProductListViewHeaderDelegate, UserPushPermissionsHeaderDelegate {

    func setupPermissionsRx() {
        viewModel.pushPermissionsDisabledWarning.asObservable().filter {$0 != nil} .bindNext { [weak self] _ in
            self?.productListView.refreshDataView()
        }.addDisposableTo(disposeBag)
    }

    func registerHeader(collectionView: UICollectionView) {
        let headerNib = UINib(nibName: UserPushPermissionsHeader.reusableID, bundle: nil)
        collectionView.registerNib(headerNib, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader,
                                   withReuseIdentifier: UserPushPermissionsHeader.reusableID)
    }

    func heightForHeader() -> CGFloat {
        guard let showWarning = viewModel.pushPermissionsDisabledWarning.value where showWarning else { return 0 }
        return UserPushPermissionsHeader.viewHeight
    }

    func viewForHeader(collectionView: UICollectionView, kind: String, indexPath: NSIndexPath) -> UICollectionReusableView {
        guard let showWarning = viewModel.pushPermissionsDisabledWarning.value where showWarning else { return UICollectionReusableView() }
        guard let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind,                                                                                                      withReuseIdentifier: UserPushPermissionsHeader.reusableID, forIndexPath: indexPath) as? UserPushPermissionsHeader
            else { return UICollectionReusableView() }
        header.delegate = self
        header.messageLabel.text = LGLocalizedString.profilePermissionsHeaderMessage
        return header
    }

    func pushPermissionHeaderPressed() {
        viewModel.pushPermissionsWarningPressed()
    }
}
