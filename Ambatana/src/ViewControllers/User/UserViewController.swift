//
//  UserViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxCocoa
import RxSwift

class UserViewController: BaseViewController {
    private static let navBarUserViewHeight: CGFloat = 36
    private static let userBgViewDefaultHeight: CGFloat = 150

    private var navBarBgImage: UIImage?
    private var navBarShadowImage: UIImage?
    private var navBarUserView: UserView?

    @IBOutlet weak var patternView: UIView!
    @IBOutlet weak var userBgView: UIView!
    @IBOutlet weak var userBgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var userBgEffectView: UIVisualEffectView!

    @IBOutlet weak var userAvatarImageView: UIImageView!

    @IBOutlet weak var userLabelsContainer: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userBgImageView: UIImageView!
    @IBOutlet weak var userBgTintView: UIView!

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainScrollContentView: UIView!
    private var viewPager: LGViewPager
    private var pages: [BaseView]

    private var viewModel: UserViewModel
    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

    init(viewModel: UserViewModel) {
        let size = CGSize(width: CGFloat.max, height: UserViewController.navBarUserViewHeight)
        self.navBarUserView = UserView.userView(.Compact(size: size))
        let viewPagerConfig = LGViewPagerConfig(tabPosition: .Top, tabLayout: .Fixed, tabHeight: 44)
        self.viewPager = LGViewPager(config: viewPagerConfig, frame: CGRect.zero)
        self.pages = []
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        super.init(viewModel: viewModel, nibName: "UserViewController")

        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navBarBgImage = navigationController?.navigationBar.backgroundImageForBarMetrics(.Default)
        navBarShadowImage = navigationController?.navigationBar.shadowImage

        setupUI()
        setupConstraints()
        setupRxBindings()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarStyle()

        // UINavigationBar's title alpha gets resetted on view appear, does not allow initial 0.0 value
        let currentAlpha: CGFloat = viewModel.navBarUserInfoShowOnTop.value ? 1 : 0
        if let navBarUserView = navBarUserView {
            navBarUserView.hidden = true
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))),
                dispatch_get_main_queue()) {
                    navBarUserView.alpha = currentAlpha
                    navBarUserView.hidden = false
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        revertNavigationBarStyle()
    }

    override var active: Bool {
        didSet {
            pages.forEach { $0.active = active }
        }
    }
}


// MARK: - Public methods

extension UserViewController {

}


// MARK: - LGViewPagerDataSource

extension UserViewController: LGViewPagerDataSource {
    func viewPagerNumberOfTabs(viewPager: LGViewPager) -> Int {
        return viewModel.tabs.value.count
    }

    func viewPager(viewPager: LGViewPager, viewForTabAtIndex index: Int) -> UIView {
        guard 0 < index && index < pages.count else { return UIView() }
        return pages[index]
    }

    func viewPager(viewPager: LGViewPager, showInfoBadgeAtIndex index: Int) -> Bool {
        return false
    }

    func viewPager(viewPager: LGViewPager, titleForSelectedTabAtIndex index: Int) -> NSAttributedString {
        return viewModel.titleForTabAtIndex(index, selected: true)
    }

    func viewPager(viewPager: LGViewPager, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString {
        return viewModel.titleForTabAtIndex(index, selected: false)
    }
}


// MARK: - LGViewPagerDelegate

extension UserViewController: LGViewPagerDelegate {
    func viewPager(viewPager: LGViewPager, willDisplayView view: UIView, atIndex index: Int) {

    }

    func viewPager(viewPager: LGViewPager, didEndDisplayingView view: UIView, atIndex index: Int) {

    }
}


// MARK: - LGViewPagerScrollDelegate

extension UserViewController: LGViewPagerScrollDelegate {
    func viewPager(viewPager: LGViewPager, didScrollToPagePosition pagePosition: CGFloat) {
        
    }
}


// MARK: - ProductListViewDataDelegate

// TODO: 🌶
extension UserViewController: ProductListViewDataDelegate {
    func productListView(productListView: ProductListView, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
        error: RepositoryError) {

    }

    func productListView(productListView: ProductListView, didSucceedRetrievingProductsPage page: UInt,
        hasProducts: Bool) {

    }

    func productListView(productListView: ProductListView, didSelectItemAtIndexPath indexPath: NSIndexPath,
        thumbnailImage: UIImage?) {

    }
}


// MARK: - UserViewModelDelegate

extension UserViewController: UserViewModelDelegate {

}


// MARK: - UIScrollViewDelegate

extension UserViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard scrollView == mainScrollView else { return }

        let percentage = scrollView.contentOffset.y / mainScrollContentView.frame.origin.y
        viewModel.setScrollPercentageRelativeToContent(percentage)

        userBgViewHeight.constant = max(UserViewController.userBgViewDefaultHeight,
            UserViewController.userBgViewDefaultHeight - scrollView.contentOffset.y)
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
        setupNavigationBar()
        setupUserAvatarView()
        setupMainScrollView()
    }

    private func setupMainView() {
        guard let patternImage = UIImage(named: "pattern_transparent") else { return }
        patternView.backgroundColor = UIColor(patternImage: patternImage)
    }

    private func setupUserAvatarView() {
        userAvatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        userAvatarImageView.layer.borderWidth = 2
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.size.width / 2.0
        userAvatarImageView.clipsToBounds = true
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

    private func setupMainScrollView() {
        // TODO: 🌶
        viewPager.dataSource = self
        viewPager.delegate = self
        viewPager.indicatorSelectedColor = StyleHelper.primaryColor
        viewPager.infoBadgeColor = StyleHelper.primaryColor
        viewPager.tabsSeparatorColor = StyleHelper.lineColor
        viewPager.translatesAutoresizingMaskIntoConstraints = false
        mainScrollContentView.addSubview(viewPager)
        viewPager.reloadData()
    }

    private func setupConstraints() {
        let views = ["vp": viewPager]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[vp]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        mainScrollContentView.addConstraints(hConstraints)
        let metrics = ["top": userAvatarImageView.frame.height/2 + 6]
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(top)-[vp]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        mainScrollContentView.addConstraints(vConstraints)
    }

    private func setNavigationBarStyle() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }

    private func revertNavigationBarStyle() {
        navigationController?.navigationBar.setBackgroundImage(navBarBgImage, forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = navBarShadowImage
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
}


// MARK: - Rx

extension UserViewController {
    private func setupRxBindings() {
        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.view.backgroundColor = bgColor
            self?.userBgTintView.backgroundColor = bgColor
            self?.viewPager.indicatorSelectedColor = bgColor
        }.addDisposableTo(disposeBag)

        viewModel.navBarUserInfoShowOnTop.asObservable().distinctUntilChanged().subscribeNext { showOnTop in
            UIView.animateWithDuration(0.35) { [weak self] in
                let topAlpha: CGFloat = showOnTop ? 1 : 0
                let bottomAlpha: CGFloat = showOnTop ? 0 : 1
                self?.navBarUserView?.alpha = topAlpha
                self?.userLabelsContainer.alpha = bottomAlpha
                self?.userAvatarImageView.alpha = bottomAlpha
            }
        }.addDisposableTo(disposeBag)

        Observable.combineLatest(
            viewModel.userId.asObservable(),
            viewModel.userName.asObservable(),
            viewModel.userLocation.asObservable(),
            viewModel.userAvatarURL.asObservable()){$0}
        .subscribeNext { [weak self] (userId, userName, userLocation, userAvatar) in
            guard let navBarUserView = self?.navBarUserView else { return }
            navBarUserView.setupWith(userAvatar: userAvatar, userName: userName, userId: userId)
        }.addDisposableTo(disposeBag)

        viewModel.userBgViewHidden.asObservable().bindTo(userBgView.rx_hidden).addDisposableTo(disposeBag)
        viewModel.userBgEffectAlpha.asObservable().bindTo(userBgEffectView.rx_alpha).addDisposableTo(disposeBag)
        viewModel.userBgTintViewAlpha.asObservable().bindTo(userBgTintView.rx_alpha).addDisposableTo(disposeBag)
        
        viewModel.userName.asObservable().bindTo(userNameLabel.rx_optionalText).addDisposableTo(disposeBag)
        viewModel.userLocation.asObservable().bindTo(userLocationLabel.rx_optionalText).addDisposableTo(disposeBag)

        viewModel.userAvatarURL.asObservable().subscribeNext { [weak self] url in
            guard let strongSelf = self else { return }
            strongSelf.userAvatarImageView.sd_setImageWithURL(url,
                placeholderImage: strongSelf.viewModel.userAvatarPlaceholder.value)

            strongSelf.userBgImageView.sd_setImageWithURL(url)
        }.addDisposableTo(disposeBag)

        viewModel.tabs.asObservable().subscribeNext { [weak self] tabs in
            guard let strongSelf = self else { return }
            var newPages: [BaseView] = []
            for index in 0..<tabs.count {
                guard let pageVM = strongSelf.viewModel.productListViewModelForTabAtIndex(index) else { continue }
                let page = ProductListView(viewModel: pageVM, frame: CGRect.zero)
                page.delegate = strongSelf
                // TODO: 🌶
//            page.scrollDelegate = self
                newPages.append(page)
            }
            strongSelf.pages = newPages
        }.addDisposableTo(disposeBag)
    }
}
