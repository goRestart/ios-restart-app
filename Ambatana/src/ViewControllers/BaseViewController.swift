//
//  BaseViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import TMReachability


private struct TostableKeys {
    static var ToastViewKey = 0
    static var ToastViewTopMarginConstraintKey = 0
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
    
    
    var topBarHeight : CGFloat {
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        guard let navController = navigationController else { return statusBarHeight }
        
        return navController.navigationBar.frame.size.height + statusBarHeight
    }
    
    var tabBarHeight : CGFloat {
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
        view.addSubview(toastView)
        
        toastViewTopMarginConstraint = NSLayoutConstraint(item: toastView, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: toastViewTopMarginHidden)
        view.addConstraint(toastViewTopMarginConstraint!)
        
        let views = ["toastView": toastView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[toastView]|", options: [], metrics: nil, views: views))
    }
}

private struct ReachableKeys {
    static var ReachabilityEnabledKey = 0
    static var ReachableKey = 0
}

// Reachable!
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
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onReachabilityChanged:"), name: kReachabilityChangedNotification, object: nil)
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

public class BaseViewController: UIViewController {
    
    
    // iVars
    // > VM & active
    private var viewModel: BaseViewModel?
    private var subviews: [BaseView]
    public var active: Bool = false {
        didSet {
            // Notify the VM & the views
            viewModel?.active = active
            
            for subview in subviews {
                subview.active = active
            }
        }
    }
    
    // > Floating sell button
    public internal(set) var floatingSellButtonHidden: Bool
    
    // MARK: Lifecycle
    
    init(viewModel: BaseViewModel?, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        self.subviews = []
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
        setupToastView()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearFromBackground(false)
        updateReachableAndToastViewVisibilityIfNeeded()
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearToBackground(false)
    }
    
    // MARK: - Internal methods
    
    // MARK: > Extended lifecycle
    
    internal func viewWillAppearFromBackground(fromBackground: Bool) {
        
        // If coming from navigation, then subscribe observers
        if !fromBackground {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationDidEnterBackground:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationWillEnterForeground:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        }
        
        // Mark as active
        active = true
    }
    
    internal func viewWillDisappearToBackground(toBackground: Bool) {
        
        // If coming from navigation, then unsubscribe observers
        if !toBackground {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        }
        
        // Mark as inactive
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
    
    
    // MARK: - Private methods
    
    // MARK: > NSNotificationCenter
    
    @objc private func applicationDidEnterBackground(notification: NSNotification) {
        viewWillDisappearToBackground(true)
    }
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        viewWillAppearFromBackground(true)
    }
}