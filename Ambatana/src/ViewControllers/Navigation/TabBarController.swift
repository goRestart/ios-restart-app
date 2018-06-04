import UIKit
import RxSwift
import RxCocoa
import LGCoreKit
import LGComponents

protocol ScrollableToTop {
    func scrollToTop()
}

protocol ListingsRefreshable {
    func listingsRefresh()
}

final class TabBarController: UITabBarController {

    // UI
    private var floatingSellButton: FloatingButton
    private var floatingSellButtonMarginConstraint = NSLayoutConstraint()

    private let viewModel: TabBarViewModel
    private let bubbleNotificationManager: BubbleNotificationManager
    private var tooltip: Tooltip?
    private var featureFlags: FeatureFlaggeable
    private let tracker: Tracker
    
    private var floatingViews: [UIView?] {
        return [floatingSellButton, tooltip, bottomNotificationsContainer]
    }
    private lazy var bottomNotificationsContainer: UIView = UIView()
    
    // Rx
    private let disposeBag = DisposeBag()

    private static let appRatingTag = Int.makeRandom()
    private static let categorySelectionTag = Int.makeRandom()
    
    
    // MARK: - Lifecycle

    convenience init(viewModel: TabBarViewModel, bubbleNotificationManager: BubbleNotificationManager) {
        let featureFlags = FeatureFlags.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        self.init(viewModel: viewModel,
                  bubbleNotificationManager: bubbleNotificationManager,
                  featureFlags: featureFlags,
                  tracker: tracker)
    }
    
    init(viewModel: TabBarViewModel,
         bubbleNotificationManager: BubbleNotificationManager,
         featureFlags: FeatureFlaggeable,
         tracker: Tracker) {
        self.viewModel = viewModel
        self.bubbleNotificationManager = bubbleNotificationManager
        self.featureFlags = featureFlags
        self.tracker = tracker
        self.floatingSellButton = FloatingButton(with: R.Strings.tabBarToolTip,
                                                 image: UIImage(named: "ic_sell_white"), position: .left)
        super.init(nibName: nil, bundle: nil)
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAdminAccess()
        setupSellButton()
        setupRx()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.active = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
    }
    
    override func viewDidLayoutSubviews() {
        guard let _ = tooltip else {
            setupTooltip()
            return
        }
    }

    private func setupRx() {
        let hasNotBottomNotifications = bubbleNotificationManager.bottomNotifications.asObservable().map {
            $0.count == 0
        }
        hasNotBottomNotifications.asObservable().distinctUntilChanged().filter{ $0 }.bind { [weak self] _ in
            self?.bottomNotificationsContainer.removeFromSuperview()
        }.disposed(by: disposeBag)
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
                floatingViews.forEach { $0?.isHidden = false }
            }
            UIView.animate(withDuration: 0.35, animations: { [weak self] () -> Void in
                self?.floatingSellButton.alpha = alpha
                self?.tooltip?.alpha = alpha
                
                }, completion: { [weak self] (completed) -> Void in
                    if completed {
                        self?.floatingViews.forEach { $0?.isHidden = hidden }
                    }
                })
        } else {
            floatingViews.forEach { $0?.isHidden = hidden }
        }
    }

    /**
    Overriding this method because we cannot stick the floatingsellButton to the tabbar. Each time we push a view
    controller that has 'hidesBottomBarWhenPushed = true' tabBar is removed from view hierarchy so the constraint will
    dissapear. Also when the tabBar is set again, is added into a different layer so the constraint cannot be set again.
    */
    override func setTabBarHidden(_ hidden:Bool, animated:Bool, completion: ((Bool) -> Void)? = nil) {
        DispatchQueue.main.async {
            // Wait for the next RunLoop.
            // When closing a Modal the tabBar frame value is not yet updated and we need to wait for the next runloop
            let frame = self.tabBar.frame
            let offsetY = (hidden ? frame.size.height : 0)
            let isAnimated = animated && (self.isTabBarHidden != hidden)
            let duration: TimeInterval = (isAnimated ? TimeInterval(UITabBarControllerHideShowBarDuration) : 0.0)

            let transform = CGAffineTransform.identity.translatedBy(x: 0, y: offsetY)
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: [.curveEaseIn], animations: { [weak self] in
                            self?.floatingViews.forEach { $0?.transform = transform }
            }, completion: completion)

            super.setTabBarHidden(hidden, animated: animated)
        }
    }
    
    func showBottomBubbleNotification(data: BubbleNotificationData,
                                      alignment: BubbleNotification.Alignment,
                                      style: BubbleNotification.Style) {
        setupBottomBubbleNotificationsContainer()
        bubbleNotificationManager.showBubble(data: data,
                                             duration: 5,
                                             view: bottomNotificationsContainer,
                                             alignment: alignment,
                                             style: style)
    }
    
    func hideBottomNotifications() {
        guard bubbleNotificationManager.bottomNotifications.value.count > 0 else { return }
        bubbleNotificationManager.hideBottomNotifications()
    }
    

    // MARK: - Private methods
    // MARK: > Setup


    func setupTabBarItems() {
        guard let viewControllers = viewControllers else { return }
        for (index, vc) in viewControllers.enumerated() {
            guard let tab = Tab(index: index, featureFlags: featureFlags) else { continue }
            let tabBarItem = UITabBarItem(title: nil, image: UIImage(named: tab.tabIconImageName), selectedImage: nil)
            // UI Test accessibility Ids
            tabBarItem.set(accessibilityId: tab.accessibilityId)
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

    @available(iOS 11, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateFloatingButtonInset()
    }

    private func updateFloatingButtonInset() {
        let bottom: CGFloat = -(tabBar.frame.height + LGUIKitConstants.tabBarSellFloatingButtonDistance)
        guard bottom != floatingSellButtonMarginConstraint.constant else { return }
        floatingSellButtonMarginConstraint.constant = bottom
    }

    private func setupSellButton() {
        floatingSellButton.buttonTouchBlock = { [weak self] in
            self?.tooltip?.removeFromSuperview()
            self?.viewModel.tooltipDismissed()
            self?.setupExpandableCategoriesView()
        }
        floatingSellButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingSellButton)
        floatingSellButton.layout(with: view).centerX()

        let bottom: CGFloat = -(tabBar.frame.height + LGUIKitConstants.tabBarSellFloatingButtonDistance)
        
        floatingSellButton.layout(with: view)
            .bottom(by: bottom, constraintBlock: {[weak self] in
                self?.floatingSellButtonMarginConstraint = $0
                
            })
        floatingSellButton.layout(with: view)
            .leading(by: LGUIKitConstants.tabBarSellFloatingButtonDistance, relatedBy: .greaterThanOrEqual)
            .trailing(by: -LGUIKitConstants.tabBarSellFloatingButtonDistance,
                      relatedBy: .lessThanOrEqual)
    }
    
    private func setupTooltip() {
        guard viewModel.shouldShowRealEstateTooltip else { return }
        tooltip = Tooltip(targetView: floatingSellButton,
                          superView: view,
                          title: viewModel.realEstateTooltipText(),
                          style: .black(closeEnabled: true),
                          peakOnTop: false, actionBlock: { [weak self] in
                            self?.viewModel.tooltipDismissed()
            }, closeBlock: { [weak self] in
                self?.viewModel.tooltipDismissed()
        })
        if let toolTipShowed = tooltip {
            view.addSubview(toolTipShowed)
            setupExternalConstraintsForTooltip(toolTipShowed, targetView: floatingSellButton, containerView: view)
        }
    }
    
    private func setupBottomBubbleNotificationsContainer() {
        guard bottomNotificationsContainer.superview == nil else { return }
        view.addSubviewForAutoLayout(bottomNotificationsContainer)
        let bottom: CGFloat = -(tabBar.frame.height + Metrics.margin)
        let constraints = [
            bottomNotificationsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom),
            bottomNotificationsContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomNotificationsContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomNotificationsContainer.heightAnchor.constraint(equalToConstant: BubbleNotification.initialHeight)]
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupExpandableCategoriesView() {
        view.subviews.find(where: { $0.tag == TabBarController.categorySelectionTag })?.removeFromSuperview()
        let vm = ExpandableCategorySelectionViewModel(featureFlags: featureFlags)
        vm.delegate = self
        
        let bottomDistance = view.bounds.height - floatingSellButton.frame.maxY
        let expandableCategorySelectionView = ExpandableCategorySelectionView(frame:view.frame,
                                                                              buttonSpacing: ExpandableCategorySelectionView.distanceBetweenButtons,
                                                                              bottomDistance: -bottomDistance,
                                                                              viewModel: vm)
        expandableCategorySelectionView.tag = TabBarController.categorySelectionTag
        view.addSubview(expandableCategorySelectionView)
        expandableCategorySelectionView.layoutIfNeeded()
        floatingSellButton.hideWithAnimation()
        expandableCategorySelectionView.expand(animated: true)
    }

    private func setupBadgesRx() {
        guard let vcs = viewControllers, 0..<vcs.count ~= Tab.chats.index else { return }

        if let chatsTab = vcs[Tab.chats.index].tabBarItem {
            viewModel.chatsBadge.asObservable().bind(to: chatsTab.rx.badgeValue).disposed(by: disposeBag)
        }
       
        if let notificationsTab = vcs[Tab.notifications.index].tabBarItem {
            viewModel.notificationsBadge.asObservable().bind(to: notificationsTab.rx.badgeValue).disposed(by: disposeBag)
        }
        
        if let sellTab = vcs[Tab.sell.index].tabBarItem, viewModel.shouldShowCameraBadge {
            viewModel.sellBadge.asObservable().bind(to: sellTab.rx.badgeValue).disposed(by: disposeBag)
        }
    }
}


// MARK: - Admin

extension TabBarController: UIGestureRecognizerDelegate {

    fileprivate func setupAdminAccess() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TabBarController.longPressProfileItem(_:)))
        longPress.delegate = self
        self.tabBar.addGestureRecognizer(longPress)
    }

    @objc func longPressProfileItem(_ recognizer: UILongPressGestureRecognizer) {
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
        floatingSellButton.set(accessibilityId: .tabBarFloatingSellButton)
    }
}

// MARK: - ExpandableCategorySelectionDelegate

extension TabBarController: ExpandableCategorySelectionDelegate {
    func didPressCloseButton() {
        floatingSellButton.showWithAnimation()
    }
    
    func didPressCategory(_ category: ExpandableCategory) {
        floatingSellButton.showWithAnimation()
        let event = TrackerEvent.listingSellYourStuffButton()
        tracker.trackEvent(event)
        viewModel.expandableButtonPressed(category: category)
    }
    
    func didPressTag(_ tag: LocalMostSearchedItem) {
        floatingSellButton.showWithAnimation()
        viewModel.tagPressed(mostSearchedItem: tag)
    }
}

