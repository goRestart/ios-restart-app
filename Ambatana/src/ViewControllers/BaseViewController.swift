//
//  BaseViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import TMReachability

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
    
    // > Toast View
    var toastView: ToastView?
    private var toastViewTopMarginConstraint: NSLayoutConstraint?
    private var toastViewTopMarginShown: CGFloat {
        return UIApplication.sharedApplication().statusBarFrame.size.height + (navigationController?.navigationBar.frame.size.height ?? 0)
    }
    private var toastViewTopMarginHidden: CGFloat {
        return -(toastView?.frame.height ?? 0)
    }
    
    // > Reachability
    private var reachability: TMReachability
    var showReachabilityMessageEnabled: Bool {
        didSet {
            setReachabilityEnabled(showReachabilityMessageEnabled)
        }
    }
    
    // > Floating sell button
    public internal(set) var floatingSellButtonHidden: Bool
    
    // MARK: Lifecycle
    
    init(viewModel: BaseViewModel?, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        self.subviews = []

        self.reachability = TMReachability.reachabilityForInternetConnection()
        self.showReachabilityMessageEnabled = true
        self.toastView = ToastView.toastView()
        
        self.floatingSellButtonHidden = false
        super.init(nibName: nibNameOrNil, bundle: nil)

        // Setup
        hidesBottomBarWhenPushed = true
        
        reachability.reachableBlock = { (let reach: TMReachability!) -> Void in
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.setToastViewHidden(true)
            }
        }
        reachability.unreachableBlock = { [weak self] (let reach: TMReachability!) -> Void in
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.toastView?.setMessage(LGLocalizedString.toastNoNetwork)
                strongSelf.setToastViewHidden(false)
            }
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if showReachabilityMessageEnabled {
            guard let toastView = toastView else { return }
            toastView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(toastView)
            
            toastViewTopMarginConstraint = NSLayoutConstraint(item: toastView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: toastViewTopMarginHidden)
            view.addConstraint(toastViewTopMarginConstraint!)
            
            let views = ["toastView": toastView]
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[toastView]|", options: [], metrics: nil, views: views))
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearFromBackground(false)
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
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        
        // Mark as inactive
        active = false
    }
    
    // MARK: > Subview handling
    
    func addSubview(subview: BaseView) {
        if !subviews.contains(subview) {
            subviews.append(subview)
        }
    }
    
    func removeSubview(subview: BaseView) {
        if subviews.contains(subview) {
            subviews = subviews.filter { return $0 !== subview }
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
            self.view.layoutIfNeeded()
            
    }
    
    // MARK: - Private methods
    
    // MARK: > NSNotificationCenter
    
    @objc private func applicationDidEnterBackground(notification: NSNotification) {
        viewWillDisappearToBackground(true)
    }
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        viewWillAppearFromBackground(true)
    }
    
    // MARK: > Reachability
    
    /**
        Enables/disables reachability notifications.
    
        - parameter enabled: If reachability notifications should be enabled.
    */
    private func setReachabilityEnabled(enabled: Bool) {
        if enabled {
            reachability.startNotifier()
        }
        else {
            reachability.stopNotifier()
        }
    }
}