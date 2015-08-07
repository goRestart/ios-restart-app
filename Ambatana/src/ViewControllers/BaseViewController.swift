//
//  BaseViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

public class BaseViewController: UIViewController {
    
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
    
    // MARK: Lifecycle
    
    init(viewModel: BaseViewModel?, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        self.subviews = []
        super.init(nibName: nibNameOrNil, bundle: nil)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        if !contains(subviews, subview) {
            subview.active = true
            subviews.append(subview)
        }
    }
    
    func removeSubview(subview: BaseView) {
        if contains(subviews, subview) {
            subview.active = false
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
}