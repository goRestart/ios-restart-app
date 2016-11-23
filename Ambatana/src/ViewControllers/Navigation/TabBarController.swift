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
    private var floatingSellButton: FloatingButton
    private var floatingSellButtonMarginConstraint = NSLayoutConstraint()

    private let viewModel: TabBarViewModel
    private var tooltip: Tooltip?
    private var featureFlags: FeatureFlaggeable
    
    // Rx
    private let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle

    convenience init(viewModel: TabBarViewModel) {
        let featureFlags = FeatureFlags.sharedInstance
        self.init(viewModel: viewModel, featureFlags: featureFlags)
    }
    
    init(viewModel: TabBarViewModel, featureFlags: FeatureFlaggeable) {
        self.floatingSellButton = FloatingButton()
        self.viewModel = viewModel
        self.featureFlags = featureFlags
        super.init(nibName: nil, bundle: nil)
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self

        setupAdminAccess()
        setupSellButtons()

        setupCommercializerRx()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.active = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didAppear()
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
                tooltip?.hidden = false
            }
            UIView.animateWithDuration(0.35, animations: { [weak self] () -> Void in
                self?.floatingSellButton.alpha = alpha
                self?.tooltip?.alpha = alpha
                }, completion: { [weak self] (completed) -> Void in
                    if completed {
                        self?.floatingSellButton.hidden = hidden
                        self?.tooltip?.hidden = hidden
                    }
                })
        } else {
            floatingSellButton.hidden = hidden
            tooltip?.hidden = hidden
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
            guard let tab = Tab(index: index, featureFlags: featureFlags) else { continue }
            let tabBarItem = UITabBarItem(title: nil, image: UIImage(named: tab.tabIconImageName), selectedImage: nil)
            // UI Test accessibility Ids
            tabBarItem.accessibilityId = tab.accessibilityId
            // Customize the selected appereance
            if let imgWColor = tabBarItem.selectedImage?.imageWithColor(UIColor.tabBarIconUnselectedColor) {
                tabBarItem.image = imgWColor.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            } else {
                tabBarItem.image = UIImage()
            }
            tabBarItem.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)
            vc.tabBarItem = tabBarItem
        }
        setupBadgesRx()
    }

    private func setupSellButtons() {
        floatingSellButton.sellCompletion = { [weak self] in self?.sellButtonPressed() }
        floatingSellButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingSellButton)

        let sellCenterXConstraint = NSLayoutConstraint(item: floatingSellButton, attribute: .CenterX,
                                    relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        floatingSellButtonMarginConstraint = NSLayoutConstraint(item: floatingSellButton, attribute: .Bottom,
                                                relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1,
                                                constant: -(tabBar.frame.height + 15)) // 15 above tabBar
        view.addConstraints([sellCenterXConstraint, floatingSellButtonMarginConstraint])

        let views: [String: AnyObject] = ["fsb" : floatingSellButton]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=15)-[fsb]-(>=15)-|",
                                                                          options: [], metrics: nil, views: views)
        view.addConstraints(hConstraints)
    }

    private func setupBadgesRx() {
        guard let vcs = viewControllers where 0..<vcs.count ~= Tab.Chats.index else { return }

        let chatsTab = vcs[Tab.Chats.index].tabBarItem
        viewModel.chatsBadge.asObservable().bindTo(chatsTab.rx_badgeValue).addDisposableTo(disposeBag)

        let notificationsTab = vcs[Tab.Notifications.index].tabBarItem
        viewModel.notificationsBadge.asObservable().bindTo(notificationsTab.rx_badgeValue).addDisposableTo(disposeBag)
    }

    
    // MARK: > Action

    dynamic func sellButtonPressed() {
        viewModel.sellButtonPressed()
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

        // Pop previous navigation to root
        navBarCtl.popToRootViewControllerAnimated(false)
        navBarCtl.tabBarController?.setTabBarHidden(false, animated: false)

        selectedIndex = tab.index

        // Notify the delegate, as programmatically change doesn't do it
        delegate?.tabBarController?(self, didSelectViewController: vc)
    }
}


// MARK: - TabBarViewModelDelegate

extension TabBarController: TabBarViewModelDelegate {
    func vmSwitchToTab(tab: Tab, force: Bool) {
        switchToTab(tab, checkIfShouldSwitch: !force)
    }

    func vmShowTooltipAtSellButtonWithText(text: NSAttributedString) {
        tooltip = Tooltip(targetView: floatingSellButton, superView: view, title: text, style: .Black(closeEnabled: true),
                              peakOnTop: false, actionBlock: { [weak self] in
            self?.viewModel.tooltipDismissed()
        }, closeBlock: { [weak self] in
            self?.viewModel.tooltipDismissed()
        })
        if let toolTipShowed = tooltip {
            view.addSubview(toolTipShowed)
            setupExternalConstraintsForTooltip(toolTipShowed, targetView: floatingSellButton, containerView: view)
        }
        view.layoutIfNeeded()
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
        if featureFlags.notificationsSection {
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
            if let url = NSURL(string: Constants.appStoreURL) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
}


extension TabBarController {
    func setAccessibilityIds() {
        floatingSellButton.sellButton.accessibilityId = AccessibilityId.TabBarFloatingSellButton
    }
}

