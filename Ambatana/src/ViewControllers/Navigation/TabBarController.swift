//
//  TabBarController.swift
//  LetGo
//
//  Created by AHL on 17/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import LGCoreKit

protocol ScrollableToTop {
    func scrollToTop()
}

protocol ProductsRefreshable {
    func productsRefresh()
}

final class TabBarController: UITabBarController {

    // UI
    private var floatingSellButton = FloatingButton()
    private var floatingSellButtonMarginConstraint = NSLayoutConstraint()
    private let sellButton = UIButton()

    private let viewModel: TabBarViewModel

    // Rx
    private let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle

    init(viewModel: TabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAdminAccess()
        setupSellButtons()

        setupCommercializerRx()
        setupBadgesRx()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.active = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Move the sell button
        guard let tabBarItemsCount = self.tabBar.items?.count else { return }
        let itemWidth = self.tabBar.frame.width / CGFloat(tabBarItemsCount)
        sellButton.frame = CGRect(x: itemWidth * CGFloat(Tab.Sell.index), y: 0,
                                  width: itemWidth, height: tabBar.frame.height)
    }
    
    
    // MARK: - Public methods
    
    func switchToTab(tab: Tab) {
        viewModel.externalSwitchToTab(tab)
    }


    /**
    Shows/hides the sell floating button

    - parameter hidden: If should be hidden
    - parameter animated: If transition should be animated
    */
    func setSellFloatingButtonHidden(hidden: Bool, animated: Bool) {
        floatingSellButton.layer.removeAllAnimations()

        let alpha: CGFloat = hidden ? 0 : 1
        if animated {

            if !hidden {
                floatingSellButton.hidden = false
            }
            UIView.animateWithDuration(0.35, animations: { [weak self] () -> Void in
                self?.floatingSellButton.alpha = alpha
                }, completion: { [weak self] (completed) -> Void in
                    if completed {
                        self?.floatingSellButton.hidden = hidden
                    }
                })
        } else {
            floatingSellButton.hidden = hidden
        }
    }

    /**
    Overriding this method because we cannot stick the floatingsellButton to the tabbar. Each time we push a view
    controller that has 'hidesBottomBarWhenPushed = true' tabBar is removed from view hierarchy so the constraint will
    dissapear. Also when the tabBar is set again, is added into a different layer so the constraint cannot be set again.
    */
    override func setTabBarHidden(hidden:Bool, animated:Bool, completion: (Bool -> Void)? = nil) {
        let floatingOffset : CGFloat = (hidden ? -15 : -(tabBar.frame.height + 15))
        floatingSellButtonMarginConstraint.constant = floatingOffset
        super.setTabBarHidden(hidden, animated: animated, completion: completion)
    }

    /**
     Shows the app rating if needed.

     - param source: The source.
     - returns: Whether app rating has been shown or not
     */
    func showAppRatingViewIfNeeded(source: EventParameterRatingSource) -> Bool {
        guard RatingManager.sharedInstance.shouldShowRating else { return false}
        return showAppRatingView(source)
    }

    func showAppRatingView(source: EventParameterRatingSource) -> Bool {
        guard let nav = selectedViewController as? UINavigationController,
            let ratingView = AppRatingView.ratingView(source) else { return false}

        ratingView.setupWithFrame(nav.view.frame)
        ratingView.delegate = self
        view.addSubview(ratingView)
        return true
    }


    // MARK: - Private methods
    // MARK: > Setup


    func setupTabBarItems() {
        guard let viewControllers = viewControllers else { return }
        for (index, vc) in viewControllers.enumerate() {
            guard let tab = Tab(index: index) else { continue }
            let tabBarItem = UITabBarItem(title: nil, image: UIImage(named: tab.tabIconImageName), selectedImage: nil)

            // Customize the selected appereance
            if let imageItem = tabBarItem.selectedImage {
                tabBarItem.image = imageItem.imageWithColor(UIColor.tabBarIconUnselectedColor)
                    .imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            } else {
                tabBarItem.image = UIImage()
            }
            tabBarItem.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)
            vc.tabBarItem = tabBarItem
        }
    }

    private func setupSellButtons() {
        // set sell button as a custom one
        sellButton.addTarget(self, action: #selector(TabBarController.sellButtonPressed),
                             forControlEvents: UIControlEvents.TouchUpInside)
        sellButton.setImage(UIImage(named: Tab.Sell.tabIconImageName), forState: UIControlState.Normal)
        tabBar.addSubview(sellButton)

        guard let floatingSellBtn = FloatingButton.floatingButtonWithTitle(LGLocalizedString.tabBarToolTip,
                                                                icon: UIImage(named: "ic_sell_white")) else { return }
        floatingSellButton = floatingSellBtn
        floatingSellButton.addTarget(self, action: #selector(TabBarController.sellButtonPressed),
                                     forControlEvents: UIControlEvents.TouchUpInside)
        floatingSellButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingSellButton)

        let sellCenterXConstraint = NSLayoutConstraint(item: floatingSellButton, attribute: .CenterX,
                                    relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        floatingSellButtonMarginConstraint = NSLayoutConstraint(item: floatingSellButton, attribute: .Bottom,
                                                relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1,
                                                constant: -(tabBar.frame.height + 15)) // 15 above tabBar
        view.addConstraints([sellCenterXConstraint,floatingSellButtonMarginConstraint])
    }

    private func setupBadgesRx() {
        guard let vcs = viewControllers where 0..<vcs.count ~= Tab.Chats.index else { return }

        let chatsTab = vcs[Tab.Chats.index].tabBarItem
        NotificationsManager.sharedInstance.unreadMessagesCount.asObservable().map {
            $0.flatMap { $0 > 0 ? String($0) : nil }
        }.bindTo(chatsTab.rx_badgeValue).addDisposableTo(disposeBag)

        let notificationsTab = vcs[Tab.Notifications.index].tabBarItem
        NotificationsManager.sharedInstance.unreadNotificationsCount.asObservable().map {
            $0.flatMap { $0 > 0 ? String($0) : nil }
        }.bindTo(notificationsTab.rx_badgeValue).addDisposableTo(disposeBag)
    }

    
    // MARK: > Action

    dynamic func sellButtonPressed() {
        viewModel.sellButtonPressed()
    }

    func openSellFromBannerCell(designType: String) {
        viewModel.sellFromBannerCell(designType)
    }

    func openUserRating(source: RateUserSource, data: RateUserData) {
        viewModel.userRating(source, data: data)
    }

    
    // MARK: > UI

    /**
     Pops the current navigation controller to root and switches to the given tab.

     - parameter The: tab to go to.
     */
    private func switchToTab(tab: Tab, checkIfShouldSwitch: Bool) {
        guard let navBarCtl = selectedViewController as? UINavigationController else { return }
        guard let viewControllers = viewControllers where tab.index < viewControllers.count else { return }
        guard let vc = (viewControllers as NSArray).objectAtIndex(tab.index) as? UIViewController else { return }
        if checkIfShouldSwitch {
            let shouldSelectVC = delegate?.tabBarController?(self, shouldSelectViewController: vc) ?? true
            guard shouldSelectVC else { return }
        }

        selectedIndex = tab.index

        // Pop previous navigation to root
        navBarCtl.popToRootViewControllerAnimated(false)

        // Notify the delegate, as programmatically change doesn't do it
        delegate?.tabBarController?(self, didSelectViewController: vc)
    }

    private func refreshSelectedProductsRefreshable() {
        if let navVC = selectedViewController as? UINavigationController, topVC = navVC.topViewController,
        refreshable = topVC as? ProductsRefreshable where topVC.isViewLoaded() {
            refreshable.productsRefresh()
        }
    }

    private func tabFromController(viewController: UIViewController) -> Tab? {
        let mainController = viewController.navigationController ?? viewController
        guard let viewControllers = viewControllers else { return nil }
        let vcIdx = (viewControllers as NSArray).indexOfObject(mainController)
        guard let tab = Tab(index: vcIdx) else { return nil }
        return tab
    }
}


// MARK: - TabBarViewModelDelegate

extension TabBarController: TabBarViewModelDelegate {
    func vmSwitchToTab(tab: Tab, force: Bool) {
        switchToTab(tab, checkIfShouldSwitch: !force)
    }
}


// MARK: - Commercializer (ALL THIS SHOULD BE HANDLED IN A COORDINATOR)

extension TabBarController {

    private func setupCommercializerRx() {
        CommercializerManager.sharedInstance.commercializers.asObservable().subscribeNext { [weak self] data in
            self?.openCommercializer(data)
        }.addDisposableTo(disposeBag)
    }

    private func openCommercializer(data: CommercializerData) {
        let vc: UIViewController
        if data.shouldShowPreview {
            let viewModel = CommercialPreviewViewModel(productId: data.productId, commercializer: data.commercializer)
            vc = CommercialPreviewViewController(viewModel: viewModel)
        } else {
            guard let viewModel = CommercialDisplayViewModel(commercializers: [data.commercializer],
                                                             productId: data.productId,
                                                             source: .External,
                                                             isMyVideo: data.isMyVideo) else { return }
            vc = CommercialDisplayViewController(viewModel: viewModel)
        }

        if let presentedVC = presentedViewController {
            presentedVC.dismissViewControllerAnimated(false, completion: nil)
        }

        presentViewController(vc, animated: true, completion: nil)
    }
}


// MARK: - Admin

extension TabBarController: UIGestureRecognizerDelegate {

    private func setupAdminAccess() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TabBarController.longPressProfileItem(_:)))
        longPress.delegate = self
        self.tabBar.addGestureRecognizer(longPress)
    }

    func longPressProfileItem(recognizer: UILongPressGestureRecognizer) {
        guard AdminViewController.canOpenAdminPanel() else { return }
        let admin = AdminViewController()
        let nav = UINavigationController(rootViewController: admin)
        presentViewController(nav, animated: true, completion: nil)
    }

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if FeatureFlags.notificationsSection {
            return selectedIndex == Tab.Home.index // Home tab because it won't show the login modal view
        } else {
            return selectedIndex == Tab.Categories.index // Categories tab because it won't show the login modal view
        }
    }
}

extension TabBarController: AppRatingViewDelegate {
    func appRatingViewDidSelectRating(rating: Int) {
        if rating <= 3 {
            guard let url = LetgoURLHelper
                .buildContactUsURL(Core.myUserRepository.myUser,
                                   installation: Core.installationRepository.installation) else { return }
            openInternalUrl(url)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: Constants.appStoreURL)!)
        }
    }
}
