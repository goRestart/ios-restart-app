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
    fileprivate var incentiviseScrollBanner: IncentiviseScrollBanner
    
    // Rx
    fileprivate let disposeBag = DisposeBag()

    fileprivate static let appRatingTag = Int.makeRandom()

    
    // MARK: - Lifecycle

    convenience init(viewModel: TabBarViewModel) {
        let featureFlags = FeatureFlags.sharedInstance
        self.init(viewModel: viewModel, featureFlags: featureFlags)
    }
    
    init(viewModel: TabBarViewModel, featureFlags: FeatureFlaggeable) {
        self.incentiviseScrollBanner = IncentiviseScrollBanner()
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

        setupAdminAccess()
        setupIncentiviseScrollBanner()
        setupSellButton()
        setupScrollBannerRx()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.active = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
    }

    
    // MARK: - Public methods

    /**
     Pops the current navigation controller to root and switches to the given tab.

     - parameter The: tab to go to.
     */
    func switchTo(tab: Tab) {
        guard let viewControllers = viewControllers, 0..<viewControllers.count ~= tab.index else { return }
        let vc = viewControllers[tab.index]

        if let navBarCtl = selectedViewController as? UINavigationController {
            _ = navBarCtl.popToRootViewController(animated: false)
        }

        setTabBarHidden(false, animated: false)

        selectedIndex = tab.index
        // Notify the delegate, as programmatically change doesn't do it
        delegate?.tabBarController?(self, didSelect: vc)
    }

    func clearAllPresented(_ completion: (() -> Void)?) {
        if let selectedVC = selectedViewController {
            selectedVC.dismissAllPresented() { [weak self] in
                self?.dismissAllPresented(completion)
            }
        } else {
            dismissAllPresented(completion)
        }
    }

    func showAppRatingView(_ source: EventParameterRatingSource) {
        view.subviews.find(where: { $0.tag == TabBarController.appRatingTag })?.removeFromSuperview()
        guard let ratingView = AppRatingView.ratingView(source) else { return }

        ratingView.setupWithFrame(view.frame)
        ratingView.delegate = self
        ratingView.tag = TabBarController.appRatingTag
        view.addSubview(ratingView)
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
        super.setTabBarHidden(hidden, animated: animated, completion: { [weak self] _ in
            self?.viewModel.tabBarChangeVisibility(hidden: hidden)
        })
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
    
    private func setupIncentiviseScrollBanner() {
        guard viewModel.shouldSetupScrollBanner else { return }
        incentiviseScrollBanner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(incentiviseScrollBanner)
        view.bringSubview(toFront: incentiviseScrollBanner)
        incentiviseScrollBanner.layout(with: tabBar).bottom().left().right()
        incentiviseScrollBanner.layout().height(tabBar.frame.height*2)
    }

    private func setupSellButton() {
        
        floatingSellButton.buttonTouchBlock = { [weak self] in self?.viewModel.sellButtonPressed() }
        floatingSellButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingSellButton)
        floatingSellButton.layout(with: view).centerX()
        floatingSellButton.layout(with: view).bottom(by: -(tabBar.frame.height + LGUIKitConstants.tabBarSellFloatingButtonDistance), constraintBlock: {[weak self] in self?.floatingSellButtonMarginConstraint = $0 })
        floatingSellButton.layout(with: view).leading(by: LGUIKitConstants.tabBarSellFloatingButtonDistance, relatedBy: .greaterThanOrEqual).trailing(by: -LGUIKitConstants.tabBarSellFloatingButtonDistance, relatedBy: .lessThanOrEqual)
    }

    private func setupBadgesRx() {
        guard let vcs = viewControllers, 0..<vcs.count ~= Tab.chats.index else { return }

        if let chatsTab = vcs[Tab.chats.index].tabBarItem {
            viewModel.chatsBadge.asObservable().bindTo(chatsTab.rx.badgeValue).addDisposableTo(disposeBag)
        }

        if let profileTab = vcs[Tab.profile.index].tabBarItem {
            viewModel.favoriteBadge.asObservable().bindTo(profileTab.rx.badgeValue).addDisposableTo(disposeBag)
        }
       
        if let notificationsTab = vcs[Tab.notifications.index].tabBarItem {
            viewModel.notificationsBadge.asObservable().bindTo(notificationsTab.rx.badgeValue).addDisposableTo(disposeBag)
        }
    }
    
    private func setupScrollBannerRx() {
        viewModel.hideScrollBanner.asObservable().bindNext({ [weak self] hidden in
            self?.incentiviseScrollBanner.isHidden = hidden
        }).addDisposableTo(disposeBag)
    }

    
    // MARK: > UI
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
        return selectedIndex == Tab.home.index // Home tab because it won't show the login modal view
    }
}

extension TabBarController: AppRatingViewDelegate {
    func appRatingViewDidSelectRating(_ rating: Int) {
        viewModel.navigator?.openAppStore()
    }
}


extension TabBarController {
    func setAccessibilityIds() {
        floatingSellButton.isAccessibilityElement = true
        floatingSellButton.accessibilityId = AccessibilityId.tabBarFloatingSellButton
    }
}

