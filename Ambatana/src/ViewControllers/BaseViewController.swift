//
//  BaseViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import TMReachability


// MARK: - ToastView

private struct TostableKeys {
    static var ToastViewKey = 0
    static var ToastViewBottomMarginConstraintKey = 0
}

private struct NavigationBarKeys {
    static var letTouchesPass = 0
    static var viewsToIgnoreTouchersFor = 0
    static var outOfBoundsViewsToForceTouches = 0
}


extension UINavigationBar {

    var outOfBoundsViewsToForceTouches: [UIView] {
        get {
            let views = objc_getAssociatedObject(self, &NavigationBarKeys.outOfBoundsViewsToForceTouches) as? [UIView]
            return views ?? []
        }
        set {
            objc_setAssociatedObject(
                self,
                &NavigationBarKeys.outOfBoundsViewsToForceTouches,
                newValue as [UIView]?,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }


    var viewsToIgnoreTouchesFor: [UIView] {
        get {
            let views = objc_getAssociatedObject(self, &NavigationBarKeys.viewsToIgnoreTouchersFor) as? [UIView]
            return views ?? []
        }
        set {
            objc_setAssociatedObject(
                self,
                &NavigationBarKeys.viewsToIgnoreTouchersFor,
                newValue as [UIView]?,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    func forceTouchesFor(_ view: UIView) {
        var views = outOfBoundsViewsToForceTouches
        views.append(view)
        outOfBoundsViewsToForceTouches = views
    }
    
    func endForceTouchesFor(_ view: UIView) {
        var views = outOfBoundsViewsToForceTouches
        if let indexToRemove = views.index(of: view) {
            views.remove(at: indexToRemove)
        }
        outOfBoundsViewsToForceTouches = views
    }

    func ignoreTouchesFor(_ view: UIView) {
        var views = viewsToIgnoreTouchesFor
        views.append(view)
        viewsToIgnoreTouchesFor = views
    }
    
    func endIgnoreTouchesFor(_ view: UIView) {
        var views = viewsToIgnoreTouchesFor
        if let indexToRemove = views.index(of: view) {
            views.remove(at: indexToRemove)
        }
        viewsToIgnoreTouchesFor = views
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let pointInside = super.point(inside: point, with: event)

        for view in viewsToIgnoreTouchesFor {
            let convertedPoint = view.convert(point, from: self)
            if view.point(inside: convertedPoint, with: event) {
                return false
            }
        }

        for view in outOfBoundsViewsToForceTouches {
            let convertedPoint = view.convert(point, from: self)
            if view.point(inside: convertedPoint, with: event) {
                return true
            }
        }

        return pointInside
    }
}

extension UIViewController {

    var toastView: ToastView? {
        get {
            var toast = objc_getAssociatedObject(self, &TostableKeys.ToastViewKey) as? ToastView
            if toast == nil {
                toast = ToastView.toastView()
                self.toastView = toast
            }
            return toast
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &TostableKeys.ToastViewKey,
                    newValue as ToastView?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    private var toastViewBottomMarginConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &TostableKeys.ToastViewBottomMarginConstraintKey) as? NSLayoutConstraint
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &TostableKeys.ToastViewBottomMarginConstraintKey,
                    newValue as NSLayoutConstraint?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }

    var navigationBarHeight: CGFloat {
        guard let navController = navigationController else { return 0 }
        return navController.navigationBar.frame.size.height
    }

    var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    var topBarHeight: CGFloat {
        return navigationBarHeight + statusBarHeight
    }
    
    var tabBarHeight: CGFloat {
        guard let tabController = tabBarController else { return 0 }
        
        return tabController.tabBar.frame.size.height
    }
    
    private var toastViewBottomMarginVisible: CGFloat {
        guard let toastView = toastView else { return 0 }
        let toastViewHeight = toastView.height > ToastView.standardHeight ? toastView.height : ToastView.standardHeight
        // In case there's no navigation bar, we should add a margin (tipically a standard navbar height) to avoid showing the toast above close button
        guard let _ = navigationController?.navigationBar else { return (44 + toastViewHeight) }
        return (toastViewHeight)
    }
    
    private var toastViewBottomMarginHidden: CGFloat {
        return 0
    }
    
    
    /**
    Shows/hides the toast view with the given message.
    
    - parameter hidden: If the toast view should be hidden.
    */
    func setToastViewHidden(_ hidden: Bool) {
        guard let toastView = toastView else { return }
        view.bringSubview(toFront: toastView)
        toastViewBottomMarginConstraint?.constant = hidden ? toastViewBottomMarginHidden : toastViewBottomMarginVisible
        UIView.animate(withDuration: 0.35, animations: {
            toastView.alpha = hidden ? 0 : 1
            toastView.layoutIfNeeded()
        }) 
    }
    
    func setupToastView() {
        guard let toastView = toastView else { return }
        toastView.translatesAutoresizingMaskIntoConstraints = false
        toastView.alpha = 0
        toastView.isUserInteractionEnabled = false
        view.addSubview(toastView)
        
        toastViewBottomMarginConstraint = NSLayoutConstraint(item: toastView, attribute: .bottom, relatedBy: .equal,
            toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: toastViewBottomMarginHidden)
        if let bottomConstraint = toastViewBottomMarginConstraint { view.addConstraint(bottomConstraint) }
        
        let views = ["toastView": toastView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[toastView]|", options: [], metrics: nil, views: views))
    }
}


// MARK: - Reachability

private struct ReachableKeys {
    static var ReachabilityEnabledKey = 0
    static var ReachableKey = 0
}

extension UIViewController {
   
    
    private var reachabilityEnabled : Bool? {
        get {
            return (objc_getAssociatedObject(self, &ReachableKeys.ReachabilityEnabledKey) as? NSNumber)?.boolValue
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &ReachableKeys.ReachabilityEnabledKey,
                    NSNumber(value: newValue as Bool),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    private var reachable : Bool? {
        get {
            return (objc_getAssociatedObject(self, &ReachableKeys.ReachableKey) as? NSNumber)?.boolValue
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &ReachableKeys.ReachableKey,
                    NSNumber(value: newValue as Bool),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    private static var reachability: TMReachability? = {
        let result = TMReachability.forInternetConnection()
        result?.startNotifier()
        return result
    } ()
    
    /**
    Enables/disables reachability notifications.
    
    - parameter enabled: If reachability notifications should be enabled.
    */
    internal func setReachabilityEnabled(_ enabled: Bool) {
        guard enabled != reachabilityEnabled else { return }
        
        reachabilityEnabled = enabled
        if enabled {
            NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.onReachabilityChanged(_:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: nil)
        }
    }
    
    
    dynamic private func onReachabilityChanged(_ notification: Notification) {
        updateReachableAndToastViewVisibilityIfNeeded()
    }
    
    
    func updateReachableAndToastViewVisibilityIfNeeded() {
        // Update reachable if changed
        let newReachableValue = UIViewController.reachability?.isReachable() ?? false
        guard newReachableValue != reachable else { return }
        reachable = UIViewController.reachability?.isReachable() ?? false
        
        // Show/hide toast
        guard let reachable = reachable, let reachabilityEnabled = reachabilityEnabled else { return }
        guard reachabilityEnabled else { return }
        
        if !reachable {
            toastView?.title = LGLocalizedString.toastNoNetwork
        }
        setToastViewHidden(reachable)
    }
}


// MARK: - NavigationBar

enum NavBarTransparentSubStyle {
    case dark, light
}

enum NavBarBackgroundStyle {
    case transparent(substyle: NavBarTransparentSubStyle)
    case `default`
    case custom(background: UIImage, shadow: UIImage)

    var tintColor: UIColor {
        switch self {
        case let .transparent(substyle):
            switch substyle {
            case .dark:
                return UIColor.clearBarButton
            case .light:
                return UIColor.lightBarButton
            }
        case .default, .custom:
            return UIColor.lightBarButton
        }
    }

    var titleColor: UIColor {
        switch self {
        case let .transparent(substyle):
            switch substyle {
            case .dark:
                return UIColor.clearBarTitle
            case .light:
                return UIColor.lightBarTitle
            }
        case .default, .custom:
            return UIColor.lightBarTitle
        }
    }
}

enum NavBarTitleStyle {
    case text(String?)
    case image(UIImage)
    case custom(UIView)
}

extension UIViewController {

    func setNavBarTitle(_ title: String?) {
        setNavBarTitleStyle(.text(title))
    }

    func setNavBarTitleStyle(_ style: NavBarTitleStyle) {
        switch style {
        case let .text(text):
            self.navigationItem.title = text
        case let .image(image):
            self.navigationItem.titleView = UIImageView(image: image)
        case let .custom(view):
            self.navigationItem.titleView = view
        }
    }

    func setNavBarBackButton(_ icon: UIImage?) {
        guard !isRootViewController() else { return }
        let backIconImage = icon ?? UIImage(named: "navbar_back")
        let backButton = UIBarButtonItem(image: backIconImage, style: UIBarButtonItemStyle.plain,
                                         target: self, action: #selector(UIViewController.popBackViewController))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
    }
    
    func setNavBarBackgroundStyle(_ style: NavBarBackgroundStyle) {
        switch style {
        case .transparent:
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
        case .default:
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.shadowImage = nil
        case let .custom(background, shadow):
            navigationController?.navigationBar.setBackgroundImage(background, for: .default)
            navigationController?.navigationBar.shadowImage = shadow
        }

        navigationController?.navigationBar.tintColor = style.tintColor
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.pageTitleFont,
                                                                   NSForegroundColorAttributeName : style.titleColor]
    }
}


// MARK: - BaseViewController

class BaseViewController: UIViewController, TabBarShowable {

    // VM & active
    private var viewModel: BaseViewModel?
    private var subviews: [BaseView]
    private var firstAppear: Bool = true
    private var firstWillAppear: Bool = true
    private var firstLayout: Bool = true
    var active: Bool = false {
        didSet {
            // Notify the VM & the views
            viewModel?.active = active
            
            for subview in subviews {
                subview.active = active
            }
        }
    }
    var hasTabBar: Bool = false
    
    // UI
    private let statusBarStyle: UIStatusBarStyle
    private let previousStatusBarStyle: UIStatusBarStyle
    private let navBarBackgroundStyle: NavBarBackgroundStyle
    private var swipeBackGestureEnabled: Bool
    var floatingSellButtonHidden: Bool
    private(set) var didCallViewDidLoaded: Bool = false


    // MARK: Lifecycle

    init(viewModel: BaseViewModel?, nibName nibNameOrNil: String?, statusBarStyle: UIStatusBarStyle = .default,
         navBarBackgroundStyle: NavBarBackgroundStyle = .default, swipeBackGestureEnabled: Bool = true) {
        self.viewModel = viewModel
        self.subviews = []
        self.statusBarStyle = statusBarStyle
        self.previousStatusBarStyle = UIApplication.shared.statusBarStyle
        self.navBarBackgroundStyle = navBarBackgroundStyle
        self.floatingSellButtonHidden = false
        self.swipeBackGestureEnabled = swipeBackGestureEnabled
        super.init(nibName: nibNameOrNil, bundle: nil)

        // Setup
        hidesBottomBarWhenPushed = true
        setReachabilityEnabled(true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func popBackViewController() {
        let viewModelDidHandleBack = viewModel?.backButtonPressed() ?? false
        if !viewModelDidHandleBack {
            super.popBackViewController()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        didCallViewDidLoaded = true
        setNavBarBackButton(nil)
        setupToastView()
        
        //Listen to status bar changes
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.statusBarDidShow(_:)),
            name: NSNotification.Name(rawValue: StatusBarNotification.StatusBarWillShow.rawValue), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearFromBackground(false)
        if firstWillAppear {
            viewWillFirstAppear(animated)
            firstWillAppear = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearToBackground(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            viewDidFirstAppear(animated)
            firstAppear = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstLayout {
            viewDidFirstLayoutSubviews()
            firstLayout = false
        }
    }
    
    func viewWillFirstAppear(_ animated: Bool) {
        // implement in subclasses
    }

    func viewDidFirstAppear(_ animated: Bool) {
        // implement in subclasses
    }

    func viewDidFirstLayoutSubviews() {
        // implement in subclasses
    }
    
    // MARK: Internal methods
    
    // MARK: > Extended lifecycle
    
    internal func viewWillAppearFromBackground(_ fromBackground: Bool) {
        setNavBarBackgroundStyle(navBarBackgroundStyle)

        if !fromBackground {
            UIApplication.shared.setStatusBarStyle(statusBarStyle, animated: true)

            NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        }
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = swipeBackGestureEnabled
        
        updateReachableAndToastViewVisibilityIfNeeded()
        active = true
    }
    
    internal func viewWillDisappearToBackground(_ toBackground: Bool) {
        
        if !toBackground {
            if !isRootViewController() {
                UIApplication.shared.setStatusBarStyle(previousStatusBarStyle, animated: true)
            }

            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        }

        active = false
    }
    
    // MARK: > Subview handling
    
    func addSubview(_ subview: BaseView) {
        //Adding to managed subviews
        if !subviews.contains(subview) {
            subviews.append(subview)
            
            //Set current state to subview
            subview.active = self.active
        }
    }
    
    func removeSubview(_ subview: BaseView) {
        if subviews.contains(subview) {
            subviews = subviews.filter { return $0 !== subview }
            
            //Set inactive state to subview
            subview.active = false
        }
    }
    
    
    // MARK: Private methods
    
    // MARK: > NSNotificationCenter
    
    dynamic private func applicationDidEnterBackground(_ notification: Notification) {
        viewWillDisappearToBackground(true)
    }
    
    dynamic private func applicationWillEnterForeground(_ notification: Notification) {
        viewWillAppearFromBackground(true)
    }

    dynamic func statusBarDidShow(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { [weak self] in
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
        }
    }
}
