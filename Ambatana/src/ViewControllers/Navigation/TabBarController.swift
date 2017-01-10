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
    fileprivate var floatingSellButton: FloatingButton
    fileprivate var floatingSellButtonMarginConstraint = NSLayoutConstraint()

    fileprivate let viewModel: TabBarViewModel
    fileprivate var tooltip: Tooltip?
    fileprivate var featureFlags: FeatureFlaggeable
    
    // Rx
    fileprivate let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle

    convenience init(viewModel: TabBarViewModel) {
        let featureFlags = FeatureFlags.sharedInstance
        self.init(viewModel: viewModel, featureFlags: featureFlags)
    }
    
    init(viewModel: TabBarViewModel, featureFlags: FeatureFlaggeable) {
        self.floatingSellButton = FloatingButton(with: LGLocalizedString.tabBarToolTip, image: UIImage(named: "ic_sell_white"), position: .left)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.active = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didAppear()
    }

    
    // MARK: - Public methods
    
    func switchToTab(_ tab: Tab, completion: (() -> ())? = nil) {
        viewModel.externalSwitchToTab(tab, completion: completion)
    }


    /**
    Shows/hides the sell floating button

    - parameter hidden: If should be hidden
    - parameter animated: If transition should be animated
    */
    func setSellFloatingButtonHidden(_ hidden: Bool, animated: Bool) {
        floatingSellButton.layer.removeAllAnimations()

        let alpha: CGFloat = hidden ? 0 : 1
        if animated {
            if !hidden {
                floatingSellButton.isHidden = false
                tooltip?.isHidden = false
            }
            UIView.animate(withDuration: 0.35, animations: { [weak self] () -> Void in
                self?.floatingSellButton.alpha = alpha
                self?.tooltip?.alpha = alpha
                }, completion: { [weak self] (completed) -> Void in
                    if completed {
                        self?.floatingSellButton.isHidden = hidden
                        self?.tooltip?.isHidden = hidden
                    }
                })
        } else {
            floatingSellButton.isHidden = hidden
            tooltip?.isHidden = hidden
        }
    }

    /**
    Overriding this method because we cannot stick the floatingsellButton to the tabbar. Each time we push a view
    controller that has 'hidesBottomBarWhenPushed = true' tabBar is removed from view hierarchy so the constraint will
    dissapear. Also when the tabBar is set again, is added into a different layer so the constraint cannot be set again.
    */
    override func setTabBarHidden(_ hidden:Bool, animated:Bool, completion: ((Bool) -> Void)? = nil) {
        let floatingOffset : CGFloat = (hidden ? -15 : -(tabBar.frame.height + 15))
        floatingSellButtonMarginConstraint.constant = floatingOffset
        super.setTabBarHidden(hidden, animated: animated, completion: completion)
    }

    /**
     Shows the app rating if needed.

     - param source: The source.
     - returns: Whether app rating has been shown or not
     */
    @discardableResult
    func showAppRatingViewIfNeeded(_ source: EventParameterRatingSource) -> Bool {
        guard RatingManager.sharedInstance.shouldShowRating else { return false}
        return showAppRatingView(source)
    }

    func showAppRatingView(_ source: EventParameterRatingSource) -> Bool {
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
        for (index, vc) in viewControllers.enumerated() {
            guard let tab = Tab(index: index, featureFlags: featureFlags) else { continue }
            let tabBarItem = UITabBarItem(title: nil, image: UIImage(named: tab.tabIconImageName), selectedImage: nil)
            // UI Test accessibility Ids
            tabBarItem.accessibilityId = tab.accessibilityId
            // Customize the selected appereance
            if let imgWColor = tabBarItem.selectedImage?.imageWithColor(UIColor.tabBarIconUnselectedColor) {
                tabBarItem.image = imgWColor.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            } else {
                tabBarItem.image = UIImage()
            }
            tabBarItem.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)
            vc.tabBarItem = tabBarItem
        }
        setupBadgesRx()
    }

    private func setupSellButtons() {
        floatingSellButton.buttonTouchBlock = { [weak self] in self?.sellButtonPressed() }
        floatingSellButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingSellButton)

        let sellCenterXConstraint = NSLayoutConstraint(item: floatingSellButton, attribute: .centerX,
                                    relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        floatingSellButtonMarginConstraint = NSLayoutConstraint(item: floatingSellButton, attribute: .bottom,
                                                relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1,
                                                constant: -(tabBar.frame.height + LGUIKitConstants.tabBarSellFloatingButtonDistance))
        view.addConstraints([sellCenterXConstraint, floatingSellButtonMarginConstraint])

        let views: [String: Any] = ["fsb" : floatingSellButton]
        let metrics: [String: Any] = ["margin" : LGUIKitConstants.tabBarSellFloatingButtonDistance]
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=margin)-[fsb]-(>=margin)-|",
                                                                          options: [], metrics: metrics, views: views)
        view.addConstraints(hConstraints)
    }

    private func setupBadgesRx() {
        guard let vcs = viewControllers, 0..<vcs.count ~= Tab.chats.index else { return }

        let chatsTab = vcs[Tab.chats.index].tabBarItem
        viewModel.chatsBadge.asObservable().bindTo(chatsTab.rx.badgeValue).addDisposableTo(disposeBag)

        let profileTab = vcs[Tab.profile.index].tabBarItem
        viewModel.favoriteBadge.asObservable().bindTo(profileTab.rx.badgeValue).addDisposableTo(disposeBag)
       
        let notificationsTab = vcs[Tab.notifications.index].tabBarItem
        viewModel.notificationsBadge.asObservable().bindTo(notificationsTab.rx.badgeValue).addDisposableTo(disposeBag)
    }

    
    // MARK: > Action

    dynamic func sellButtonPressed() {
        viewModel.sellButtonPressed()
    }

    func openUserRating(_ source: RateUserSource, data: RateUserData) {
        viewModel.userRating(source, data: data)
    }

    
    // MARK: > UI

    /**
     Pops the current navigation controller to root and switches to the given tab.

     - parameter The: tab to go to.
     */
    private func switchToTab(_ tab: Tab, checkIfShouldSwitch: Bool, completion: (() -> ())?) {
        guard let navBarCtl = selectedViewController as? UINavigationController else { return }
        guard let viewControllers = viewControllers, tab.index < viewControllers.count else { return }
        guard let vc = (viewControllers as NSArray).object(at: tab.index) as? UIViewController else { return }
        if checkIfShouldSwitch {
            let shouldSelectVC = delegate?.tabBarController?(self, shouldSelect: vc) ?? true
            guard shouldSelectVC else { return }
        }

        // Dismiss all presented view controllers
        navBarCtl.dismissAllPresented { [weak self, weak navBarCtl] in
            // Pop previous navigation to root
            navBarCtl?.popToRootViewController(animated: false)
            navBarCtl?.tabBarController?.setTabBarHidden(false, animated: false)

            guard let strongSelf = self else { return }

            strongSelf.selectedIndex = tab.index
            // Notify the delegate, as programmatically change doesn't do it
            strongSelf.delegate?.tabBarController?(strongSelf, didSelect: vc)

            completion?()
        }
    }
}


// MARK: - TabBarViewModelDelegate

extension TabBarController: TabBarViewModelDelegate {
    func vmSwitchToTab(_ tab: Tab, force: Bool, completion: (() -> ())?) {
        switchToTab(tab, checkIfShouldSwitch: !force, completion: completion)
    }

    func vmShowTooltipAtSellButtonWithText(_ text: NSAttributedString) {
        tooltip = Tooltip(targetView: floatingSellButton, superView: view, title: text, style: .black(closeEnabled: true),
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

    fileprivate func setupCommercializerRx() {
        CommercializerManager.sharedInstance.commercializers.asObservable().subscribeNext { [weak self] data in
            self?.openCommercializer(data)
        }.addDisposableTo(disposeBag)
    }

    fileprivate func openCommercializer(_ data: CommercializerData) {
        let vc: UIViewController
        if data.shouldShowPreview {
            let viewModel = CommercialPreviewViewModel(productId: data.productId, commercializer: data.commercializer)
            vc = CommercialPreviewViewController(viewModel: viewModel)
        } else {
            guard let viewModel = CommercialDisplayViewModel(commercializers: [data.commercializer],
                                                             productId: data.productId,
                                                             source: .external,
                                                             isMyVideo: data.isMyVideo) else { return }
            vc = CommercialDisplayViewController(viewModel: viewModel)
        }

        if let presentedVC = presentedViewController {
            presentedVC.dismiss(animated: false, completion: nil)
        }

        present(vc, animated: true, completion: nil)
    }
}


// MARK: - Admin

extension TabBarController: UIGestureRecognizerDelegate {

    fileprivate func setupAdminAccess() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TabBarController.longPressProfileItem(_:)))
        longPress.delegate = self
        self.tabBar.addGestureRecognizer(longPress)
    }

    func longPressProfileItem(_ recognizer: UILongPressGestureRecognizer) {
        guard AdminViewController.canOpenAdminPanel() else { return }
        let admin = AdminViewController()
        let nav = UINavigationController(rootViewController: admin)
        present(nav, animated: true, completion: nil)
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if featureFlags.notificationsSection {
            return selectedIndex == Tab.home.index // Home tab because it won't show the login modal view
        } else {
            return selectedIndex == Tab.categories.index // Categories tab because it won't show the login modal view
        }
    }
}

extension TabBarController: AppRatingViewDelegate {
    func appRatingViewDidSelectRating(_ rating: Int) {
        if rating <= 3 {
            guard let url = LetgoURLHelper
                .buildContactUsURL(user: Core.myUserRepository.myUser,
                                   installation: Core.installationRepository.installation) else { return }
            openInternalUrl(url)
        } else {
            if let url = URL(string: Constants.appStoreURL) {
                UIApplication.shared.openURL(url)
            }
        }
    }
}


extension TabBarController {
    func setAccessibilityIds() {
        floatingSellButton.isAccessibilityElement = true
        floatingSellButton.accessibilityId = AccessibilityId.tabBarFloatingSellButton
    }
}

