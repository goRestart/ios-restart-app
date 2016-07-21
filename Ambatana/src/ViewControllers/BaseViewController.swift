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
    static var ToastViewTopMarginConstraintKey = 0
}

private struct NavigationBarKeys {
    static var letTouchesPass = 0
    static var viewsToIgnoreTouchersFor = 0
}

extension UINavigationBar {
    
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
    
    func ignoreTouchesFor(view: UIView) {
        var views = viewsToIgnoreTouchesFor
        views.append(view)
        viewsToIgnoreTouchesFor = views
    }
    
    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let pointInside = super.pointInside(point, withEvent: event)
        
        for view in viewsToIgnoreTouchesFor {
            let convertedPoint = view.convertPoint(point, fromView: self)
            if view.pointInside(convertedPoint, withEvent: event) {
                return false
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
    
    private var toastViewTopMarginConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &TostableKeys.ToastViewTopMarginConstraintKey) as? NSLayoutConstraint
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &TostableKeys.ToastViewTopMarginConstraintKey,
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
    
    var topBarHeight: CGFloat {
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        return navigationBarHeight + statusBarHeight
    }
    
    var tabBarHeight: CGFloat {
        guard let tabController = tabBarController else { return 0 }
        
        return tabController.tabBar.frame.size.height
    }
    
    private var toastViewTopMarginShown: CGFloat {
        return 0
    }
    
    private var toastViewTopMarginHidden: CGFloat {
        guard let toastView = toastView else { return 0 }
        return -(toastView.frame.height + topBarHeight + 100) // TODO: + 100 is too punk...
    }
    
    
    /**
    Shows/hides the toast view with the given message.
    
    - parameter hidden: If the toast view should be hidden.
    */
    func setToastViewHidden(hidden: Bool) {
        guard let toastView = toastView else { return }
        view.bringSubviewToFront(toastView)
        toastViewTopMarginConstraint?.constant = hidden ? toastViewTopMarginHidden : toastViewTopMarginShown
        UIView.animateWithDuration(0.35) {
            toastView.alpha = hidden ? 0 : 1
            toastView.layoutIfNeeded()
        }
    }
    
    func setupToastView() {
        guard let toastView = toastView else { return }
        toastView.translatesAutoresizingMaskIntoConstraints = false
        toastView.alpha = 0
        toastView.userInteractionEnabled = false
        view.addSubview(toastView)
        
        toastViewTopMarginConstraint = NSLayoutConstraint(item: toastView, attribute: .Top, relatedBy: .Equal,
            toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: toastViewTopMarginHidden)
        view.addConstraint(toastViewTopMarginConstraint!)
        
        let views = ["toastView": toastView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[toastView]|", options: [], metrics: nil, views: views))
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
                    NSNumber(bool: newValue),
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
                    NSNumber(bool: newValue),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    private static var reachability: TMReachability = {
        let result = TMReachability.reachabilityForInternetConnection()
        result.startNotifier()
        return result
    } ()
    
    /**
    Enables/disables reachability notifications.
    
    - parameter enabled: If reachability notifications should be enabled.
    */
    internal func setReachabilityEnabled(enabled: Bool) {
        guard enabled != reachabilityEnabled else { return }
        
        reachabilityEnabled = enabled
        if enabled {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.onReachabilityChanged(_:)), name: kReachabilityChangedNotification, object: nil)
        }
        else {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: kReachabilityChangedNotification, object: nil)
        }
    }
    
    
    dynamic private func onReachabilityChanged(notification: NSNotification) {
        updateReachableAndToastViewVisibilityIfNeeded()
    }
    
    
    func updateReachableAndToastViewVisibilityIfNeeded() {
        // Update reachable if changed
        let newReachableValue = UIViewController.reachability.isReachable()
        guard newReachableValue != reachable else { return }
        reachable = UIViewController.reachability.isReachable()
        
        // Show/hide toast
        guard let reachable = reachable, reachabilityEnabled = reachabilityEnabled else { return }
        guard reachabilityEnabled else { return }
        
        if !reachable {
            toastView?.title = LGLocalizedString.toastNoNetwork
        }
        setToastViewHidden(reachable)
    }
}


// MARK: - NavigationBar

enum NavBarBackgroundStyle {
    case Transparent
    case Default
    case Custom(background: UIImage, shadow: UIImage)
}

enum NavBarTitleStyle {
    case Text(String?)
    case Image(UIImage)
    case Custom(UIView)
}

extension UIViewController {

    func setNavBarTitle(title: String?) {
        setNavBarTitleStyle(.Text(title))
    }

    func setNavBarTitleStyle(style: NavBarTitleStyle) {
        switch style {
        case let .Text(text):
            self.navigationItem.title = text
        case let .Image(image):
            self.navigationItem.titleView = UIImageView(image: image)
        case let .Custom(view):
            self.navigationItem.titleView = view
        }
    }

    func setNavBarBackButton(icon: UIImage?) {
        guard !isRootViewController() else { return }
        let backIconImage = icon ?? UIImage(named: "navbar_back")
        let backButton = UIBarButtonItem(image: backIconImage, style: UIBarButtonItemStyle.Plain,
                                         target: self, action: #selector(UIViewController.popBackViewController))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
    }
    
    func setNavBarBackgroundStyle(style: NavBarBackgroundStyle) {
        switch style {
        case .Transparent:
            navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            navigationController?.navigationBar.shadowImage = UIImage()
        case .Default:
            navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
            navigationController?.navigationBar.shadowImage = nil
        case let .Custom(background, shadow):
            navigationController?.navigationBar.setBackgroundImage(background, forBarMetrics: .Default)
            navigationController?.navigationBar.shadowImage = shadow
        }
    }
}


// MARK: - BaseViewController

public class BaseViewController: UIViewController, TabBarShowable {

    // VM & active
    private var viewModel: BaseViewModel?
    private var subviews: [BaseView]
    private var firstAppear: Bool = true
    private var firstWillAppear: Bool = true
    private var firstLayout: Bool = true
    public var active: Bool = false {
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
    private let navBarBackgroundStyle: NavBarBackgroundStyle
    public internal(set) var floatingSellButtonHidden: Bool


    // MARK: Lifecycle

    init(viewModel: BaseViewModel?, nibName nibNameOrNil: String?, statusBarStyle: UIStatusBarStyle = .Default,
         navBarBackgroundStyle: NavBarBackgroundStyle = .Default) {
        self.viewModel = viewModel
        self.subviews = []
        self.statusBarStyle = statusBarStyle
        self.navBarBackgroundStyle = navBarBackgroundStyle
        self.floatingSellButtonHidden = false
        super.init(nibName: nibNameOrNil, bundle: nil)

        // Setup
        hidesBottomBarWhenPushed = true
        setReachabilityEnabled(true)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setNavBarBackButton(nil)
        setupToastView()

        //Listen to status bar changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseViewController.statusBarDidShow(_:)),
            name: StatusBarNotification.StatusBarWillShow.rawValue, object: nil)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearFromBackground(false)
        if firstWillAppear {
            viewWillFirstAppear(animated)
            firstWillAppear = false
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearToBackground(false)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            viewDidFirstAppear(animated)
            firstAppear = false
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstLayout {
            viewDidFirstLayoutSubviews()
            firstLayout = false
        }
    }
    
    public func viewWillFirstAppear(animated: Bool) {
        // implement in subclasses
    }

    public func viewDidFirstAppear(animated: Bool) {
        // implement in subclasses
    }

    public func viewDidFirstLayoutSubviews() {
        // implement in subclasses
    }
    
    // MARK: Internal methods
    
    // MARK: > Extended lifecycle
    
    internal func viewWillAppearFromBackground(fromBackground: Bool) {
        setNavBarBackgroundStyle(navBarBackgroundStyle)

        if !fromBackground {
            UIApplication.sharedApplication().setStatusBarStyle(statusBarStyle, animated: true)

            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)), name: UIApplicationDidEnterBackgroundNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIApplicationDelegate.applicationWillEnterForeground(_:)), name: UIApplicationWillEnterForegroundNotification, object: nil)
        }

        updateReachableAndToastViewVisibilityIfNeeded()
        active = true
    }
    
    internal func viewWillDisappearToBackground(toBackground: Bool) {
        
        if !toBackground {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        }

        active = false
    }
    
    // MARK: > Subview handling
    
    func addSubview(subview: BaseView) {
        //Adding to managed subviews
        if !subviews.contains(subview) {
            subviews.append(subview)
            
            //Set current state to subview
            subview.active = self.active
        }
    }
    
    func removeSubview(subview: BaseView) {
        if subviews.contains(subview) {
            subviews = subviews.filter { return $0 !== subview }
            
            //Set inactive state to subview
            subview.active = false
        }
    }
    
    
    // MARK: Private methods
    
    // MARK: > NSNotificationCenter
    
    dynamic private func applicationDidEnterBackground(notification: NSNotification) {
        viewWillDisappearToBackground(true)
    }
    
    dynamic private func applicationWillEnterForeground(notification: NSNotification) {
        viewWillAppearFromBackground(true)
    }

    dynamic func statusBarDidShow(notification: NSNotification) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue()) { [weak self] in
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
        }
    }
}
