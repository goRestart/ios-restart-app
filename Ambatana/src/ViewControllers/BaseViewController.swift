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
    
    // > Reachability
    var showReachabilityMessageEnabled: Bool = false {
        didSet {
            setReachabilityEnabled(showReachabilityMessageEnabled)
        }
    }
    private var reachability: TMReachability
    private var noNetworkView: NoNetworkView?
    
    // > Floating sell button
    public internal(set) var floatingSellButtonHidden: Bool
    
    // MARK: Lifecycle
    
    init(viewModel: BaseViewModel?, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        self.subviews = []

        self.reachability = TMReachability.reachabilityForInternetConnection()
        self.noNetworkView = NoNetworkView.noNetworkView()
        
        self.floatingSellButtonHidden = false
        super.init(nibName: nibNameOrNil, bundle: nil)

        // Setup
        hidesBottomBarWhenPushed = true
        
        reachability.reachableBlock = { [weak self] (let reach: TMReachability!) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self?.setReachabilityMessageHidden(true)
            }
        }
        reachability.unreachableBlock = { [weak self] (let reach: TMReachability!) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self?.setReachabilityMessageHidden(false)
            }
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var noNetwork = false
    private var noNetworkTopMarginConstraint: NSLayoutConstraint?
    private var noNetworkTopMarginShown: CGFloat {
        return UIApplication.sharedApplication().statusBarFrame.size.height + (navigationController?.navigationBar.frame.size.height ?? 0)
    }
    private var noNetworkTopMarginHidden: CGFloat {
        return -(noNetworkView?.frame.height ?? 0)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if showReachabilityMessageEnabled {
            if let noNetworkView = noNetworkView {
                noNetworkView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(noNetworkView)
                
                noNetworkTopMarginConstraint = NSLayoutConstraint(item: noNetworkView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: noNetworkTopMarginShown)
                if let noNetworkTopMarginConstraint = noNetworkTopMarginConstraint {
                    view.addConstraint(noNetworkTopMarginConstraint)
                }
                
                let scrollViewViews = ["noNetworkView": noNetworkView]
                view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[noNetworkView]|", options: [], metrics: nil, views: scrollViewViews))
            }
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let noNetworkTopMarginConstraint = noNetworkTopMarginConstraint {
            // Update the constant
            if noNetwork {
                noNetworkTopMarginConstraint.constant = noNetworkTopMarginShown
            }
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
    
    /**
        Shows/hides the reachability message.
    
        - parameter hidden: If the message should be hidden.
    */
    private func setReachabilityMessageHidden(hidden: Bool) {
        noNetwork = !hidden
        if let noNetworkView = noNetworkView {
            view.bringSubviewToFront(noNetworkView)
            noNetworkTopMarginConstraint?.constant = hidden ? noNetworkTopMarginHidden : noNetworkTopMarginShown
        }
    }
}