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
    private static let userBgViewDefaultHeight: CGFloat = 106

    private static let headerExpandedHeaderTop: CGFloat = 110
    private static let headerCollapsedHeaderTop: CGFloat = -23  // 23 = 46/2, where: 46 = 40 image + 6 padding

    private static let collapsePercentageUserInfoSwitch: CGFloat = 0.3
    private static let collapsePercentageUserInfoDisappear: CGFloat = -0.2

    private static let userBgTintViewMaxAlpha: CGFloat = 1.0
    private static let userBgEffectViewMaxAlpha: CGFloat = 1.0

    private var navBarBgImage: UIImage?
    private var navBarShadowImage: UIImage?
    private var navBarUserView: UserView?
    private var navBarUserViewAlphaOnDisappear: CGFloat = 0.0

    @IBOutlet weak var patternView: UIView!
    @IBOutlet weak var userBgView: UIView!
    @IBOutlet weak var userBgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var userBgEffectView: UIVisualEffectView!

    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var headerContainerViewTop: NSLayoutConstraint!
    var header: UserViewHeader?
    let headerGestureRecognizer: UIPanGestureRecognizer
    @IBOutlet weak var productListViewBackgroundView: UIView!
    @IBOutlet weak var productListView: ProfileProductListView!

    @IBOutlet weak var userLabelsContainer: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userBgImageView: UIImageView!
    @IBOutlet weak var userBgTintView: UIView!

    private var bottomInset: CGFloat = 0
    private let cellDrawer: ProductCellDrawer
    private var viewModel: UserViewModel

    private let headerCollapsePercentage = Variable<CGFloat>(0)
    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

    init(viewModel: UserViewModel) {
        let size = CGSize(width: CGFloat.max, height: UserViewController.navBarUserViewHeight)
        self.navBarUserView = UserView.userView(.CompactBorder(size: size))
        self.header = UserViewHeader.userViewHeader()
        self.headerGestureRecognizer = UIPanGestureRecognizer()
        self.viewModel = viewModel
        self.cellDrawer = ProductCellDrawerFactory.drawerForProduct(true)
        self.disposeBag = DisposeBag()
        super.init(viewModel: viewModel, nibName: "UserViewController", statusBarStyle: .LightContent)
        header?.delegate = self
        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navBarBgImage = navigationController?.navigationBar.backgroundImageForBarMetrics(.Default)
        navBarShadowImage = navigationController?.navigationBar.shadowImage

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

        setNavigationBarStyle()

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
        revertNavigationBarStyle()
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


// MARK: - ProductListViewDataDelegate

extension UserViewController: ProductListViewDataDelegate {
    func productListView(productListView: ProductListView, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
        error: RepositoryError) {
    }

    func productListView(productListView: ProductListView, didSucceedRetrievingProductsPage page: UInt,
        hasProducts: Bool) {
    }

    func productListView(productListView: ProductListView, didSelectItemAtIndexPath indexPath: NSIndexPath,
        thumbnailImage: UIImage?) {
            guard let productVM = productListView.productViewModelForProductAtIndex(indexPath.row,
                                                                    thumbnailImage: thumbnailImage) else { return }
            let vc = ProductViewController(viewModel: productVM)
            navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - ProductListViewScrollDelegate

extension UserViewController: ProductListViewScrollDelegate {
    func productListView(productListView: ProductListView, didScrollDown scrollDown: Bool) {
    }

    func productListView(productListView: ProductListView, didScrollWithContentOffsetY contentOffsetY: CGFloat) {
        updateContentInset(contentOffsetY)
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

    func vmOpenHome() {
        guard let tabBarCtl = tabBarController as? TabBarController else { return }
        tabBarCtl.switchToTab(.Home)
    }
}


// MARK: - UserViewModelDelegate

extension UserViewController : UserViewHeaderDelegate {
    func headerAvatarAction() {
        viewModel.avatarButtonPressed()
    }
}


// MARK: - Private methods
// MARK: - UI

extension UserViewController {
    private func setupUI() {
        hidesBottomBarWhenPushed = false
        automaticallyAdjustsScrollViewInsets = false

        setupUserBgView()
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
        guard let header = header else { return }
        header.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(header)

        headerGestureRecognizer.addTarget(self, action: #selector(UserViewController.handleHeaderPan))
        view.addGestureRecognizer(headerGestureRecognizer)

        let views = ["header": header]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[header]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(hConstraints)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[header]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(vConstraints)

        headerContainerViewTop.constant = UserViewController.headerExpandedHeaderTop
    }

    private func setupNavigationBar() {
        if let navBarUserView = navBarUserView {
            navBarUserView.alpha = 0
            navBarUserView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat.max, height: UserViewController.navBarUserViewHeight))
        }

        let backIcon = UIImage(named: "navbar_back_white_shadow")
        setLetGoNavigationBarStyle(navBarUserView, backIcon: backIcon)
    }

    private func setupUserBgView() {
        userBgViewHeight.constant = UserViewController.userBgViewDefaultHeight
    }

    private func setupProductListView() {
        productListViewBackgroundView.backgroundColor = StyleHelper.userProductListBgColor

        productListView.ignoreDataViewWhenSettingContentInset = true
        let contentInset = UIEdgeInsets(top: UserViewController.headerExpandedHeaderTop, left: 0, bottom: bottomInset,
                                        right: 0)

        productListView.delegate = self
        productListView.scrollDelegate = self
        productListView.contentInset = contentInset
        productListView.collectionViewContentInset = contentInset
        productListView.collectionView.scrollIndicatorInsets.top = contentInset.top
    }

    private func setNavigationBarStyle() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    private func revertNavigationBarStyle() {
        navigationController?.navigationBar.setBackgroundImage(navBarBgImage, forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = navBarShadowImage
    }

    private func updateContentInset(contentOffsetInsetY: CGFloat) {
        let minTop = UserViewController.headerCollapsedHeaderTop
        let maxTop = UserViewController.headerExpandedHeaderTop
        let top = maxTop - min(maxTop, maxTop + contentOffsetInsetY)

        headerContainerViewTop.constant = top + minTop

        let contentInset = UIEdgeInsets(top: min(maxTop, top), left: 0, bottom: bottomInset, right: 0)
        productListView.contentInset = contentInset
        productListView.collectionViewContentInset = contentInset
        productListView.collectionView.scrollIndicatorInsets.top = contentInset.top

        let percentage = 1 - (top / (maxTop - minTop))
        headerCollapsePercentage.value = percentage
    }

    dynamic private func handleHeaderPan(gestureRecognizer: UIPanGestureRecognizer) {
        guard viewModel.shouldScrollOnPan() else { return }

        let minTop = UserViewController.headerCollapsedHeaderTop
        let maxTop = UserViewController.headerExpandedHeaderTop

        let translation = gestureRecognizer.translationInView(view)
        gestureRecognizer.setTranslation(CGPoint.zero, inView: view)

        let currentInset = productListView.contentInset.top
        let top = currentInset + translation.y

        headerContainerViewTop.constant = top + minTop

        let contentInset = UIEdgeInsets(top: min(maxTop, top), left: 0, bottom: bottomInset, right: 0)
        productListView.contentInset = contentInset
        productListView.collectionViewContentInset = contentInset
        productListView.collectionView.scrollIndicatorInsets.top = contentInset.top

        let percentage = 1 - (top / (maxTop - minTop))
        headerCollapsePercentage.value = percentage
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
            self?.userBgImageView.sd_setImageWithURL(url)
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
        viewModel.userName.asObservable().bindTo(userNameLabel.rx_optionalText).addDisposableTo(disposeBag)
        viewModel.userLocation.asObservable().bindTo(userLocationLabel.rx_optionalText).addDisposableTo(disposeBag)

        Observable.combineLatest(viewModel.userAvatarURL.asObservable(),
            viewModel.userAvatarPlaceholder.asObservable()) { ($0, $1) }
            .subscribeNext { [weak self] (avatar, placeholder) in
                self?.header?.setAvatar(avatar, placeholderImage: placeholder)
        }.addDisposableTo(disposeBag)

        viewModel.userRelationText.asObservable().subscribeNext { [weak self] userRelationText in
            self?.header?.setUserRelationText(userRelationText)
        }.addDisposableTo(disposeBag)

        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.header?.selectedColor = bgColor
        }.addDisposableTo(disposeBag)

        Observable.combineLatest(viewModel.isFacebookLinked.asObservable(),
                                 viewModel.isFacebookVerified.asObservable()) { ($0, $1) }
            .subscribeNext { [weak self] (linked, verified) in
                self?.header?.setFacebookAccount(linked, isVerified: verified)
        }.addDisposableTo(disposeBag)

        Observable.combineLatest(viewModel.isGoogleLinked.asObservable(),
                                 viewModel.isGoogleVerified.asObservable()) { ($0, $1) }
            .subscribeNext { [weak self] (linked, verified) in
                self?.header?.setGoogleAccount(linked, isVerified: verified)
        }.addDisposableTo(disposeBag)

        Observable.combineLatest(viewModel.isEmailLinked.asObservable(),
                                 viewModel.isEmailVerified.asObservable()) { ($0, $1) }
            .subscribeNext { [weak self] (linked, verified) in
                self?.header?.setEmailAccount(linked, isVerified: verified)
        }.addDisposableTo(disposeBag)

        viewModel.headerMode.asObservable().subscribeNext { [weak self] mode in
            self?.header?.mode = mode
        }.addDisposableTo(disposeBag)

        // Header collapse notify percentage
        let percentage = headerCollapsePercentage.asObservable().map {
            return max(0, min(1, $0))
        }
        percentage.subscribeNext { [weak self] percentage in
            self?.header?.setCollapsePercentage(percentage)
        }.addDisposableTo(disposeBag)

        headerCollapsePercentage.asObservable().map { percentage in
            return UserViewController.userBgViewDefaultHeight * (1 + (1 - percentage))
        }.bindTo(userBgViewHeight.rx_constant).addDisposableTo(disposeBag)

        headerCollapsePercentage.asObservable()
            .subscribeNext { [weak self] percentage in
                self?.userBgEffectView.alpha = min(percentage + 0.85, UserViewController.userBgEffectViewMaxAlpha)
                self?.userBgTintView.alpha = min(percentage + 0.37, UserViewController.userBgTintViewMaxAlpha)
            }
            .addDisposableTo(disposeBag)

        // Header collapse switch
        headerCollapsePercentage.asObservable().map {
            $0 >= UserViewController.collapsePercentageUserInfoSwitch
        }.distinctUntilChanged().subscribeNext { [weak self] collapsed in
            self?.header?.collapsed = collapsed

            UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseIn, .BeginFromCurrentState], animations: {
                let topAlpha: CGFloat = collapsed ? 1 : 0
                let bottomAlpha: CGFloat = collapsed ? 0 : 1
                self?.navBarUserView?.alpha = topAlpha
                self?.userLabelsContainer.alpha = bottomAlpha
            }, completion: nil)
        }.addDisposableTo(disposeBag)

        // Header disappear
        headerCollapsePercentage.asObservable().map {
            $0 <= UserViewController.collapsePercentageUserInfoDisappear
            }.distinctUntilChanged().subscribeNext { [weak self] hidden in
                self?.header?.collapsed = hidden

                UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseIn, .BeginFromCurrentState], animations: {
                    self?.userLabelsContainer.alpha = hidden ? 0 : 1
                }, completion: nil)
            }.addDisposableTo(disposeBag)

        // Tab switch
        header?.tab.asObservable().bindTo(viewModel.tab).addDisposableTo(disposeBag)
    }

    private func setupProductListViewRxBindings() {
        viewModel.productListViewModel.asObservable().subscribeNext { [weak self] viewModel in
            self?.productListView.switchViewModel(viewModel)
            self?.productListView.refreshDataView()
            self?.productListView.scrollToTop(false)
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - ScrollableToTop

extension UserViewController: ScrollableToTop {
    func scrollToTop() {
        productListView.scrollToTop(true)
    }
}
