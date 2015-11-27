//
//  BaseViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import TMReachability
import SlackTextViewController

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
    
    var topBarHeight : CGFloat {
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        guard let navController = navigationController else { return statusBarHeight }
        
        return navController.navigationBar.frame.size.height + statusBarHeight
    }
    
    var tabBarHeight : CGFloat {
        guard let tabController = tabBarController else { return 0 }
        
        return tabController.tabBar.frame.size.height
    }
    
    // > Toast View
    var toastView: ToastView?
    private var toastViewTopMarginConstraint: NSLayoutConstraint?
    private var toastViewTopMarginShown: CGFloat {
        return 0
    }
    private var toastViewTopMarginHidden: CGFloat {
        guard let toastView = toastView else { return 0 }
        return -(toastView.frame.height + topBarHeight + 100) // TODO: + 100 is too punk...
    }
    
    // > Reachability
    private static var reachability: TMReachability = {
        let result = TMReachability.reachabilityForInternetConnection()
        result.startNotifier()
        return result
    } ()
    private var reachable : Bool?
    private var reachabilityEnabled : Bool?
    
    // > Floating sell button
    public internal(set) var floatingSellButtonHidden: Bool
    
    // MARK: Lifecycle
    
    init(viewModel: BaseViewModel?, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        self.subviews = []

        self.toastView = ToastView.toastView()
        
        self.floatingSellButtonHidden = false
        self.reachable = nil
        self.reachabilityEnabled = nil
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
        
        guard let toastView = toastView else { return }
        toastView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastView)
        
        toastViewTopMarginConstraint = NSLayoutConstraint(item: toastView, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: toastViewTopMarginHidden)
        view.addConstraint(toastViewTopMarginConstraint!)
        
        let views = ["toastView": toastView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[toastView]|", options: [], metrics: nil, views: views))
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
    
    // MARK: > UI
    
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
    
    // MARK: - Private methods
    
    // MARK: > NSNotificationCenter
    
    @objc private func applicationDidEnterBackground(notification: NSNotification) {
        viewWillDisappearToBackground(true)
    }
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        viewWillAppearFromBackground(true)
    }
    
    dynamic private func onReachabilityChanged(notification: NSNotification) {
        updateReachableAndToastViewVisibilityIfNeeded()
    }
    
    // MARK: > Reachability
    
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
    
    private func updateReachableAndToastViewVisibilityIfNeeded() {
        // Update reachable if changed
        let newReachableValue = BaseViewController.reachability.isReachable()
        guard newReachableValue != reachable else { return }
        reachable = BaseViewController.reachability.isReachable()
        
        // Show/hide toast
        guard let reachable = reachable, reachabilityEnabled = reachabilityEnabled else { return }
        guard reachabilityEnabled else { return }
        
        if !reachable {
            toastView?.title = LGLocalizedString.toastNoNetwork
        }
        setToastViewHidden(reachable)
    }
}