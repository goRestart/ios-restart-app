//
//  BaseViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

class BaseViewController: UIViewController {
    
    private var viewModel: BaseViewModel!
    private var subviews: [BaseView]!
    
    // MARK: Lifecycle
    
    init(viewModel: BaseViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        self.subviews = []
        super.init(nibName: nibNameOrNil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Controller
        viewControllerDidBecomeActive(true)
        
        // Views
        if let actualSubviews = subviews {
            for subview in actualSubviews {
                subview.viewDidBecomeActive(true)
            }
        }
        
        // Observers: listen for background/foreground notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationDidEnterBackground:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationWillEnterForeground:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Controller
        viewControllerDidBecomeActive(false)
        
        // Views
        if let actualSubviews = subviews {
            for subview in actualSubviews {
                subview.viewDidBecomeActive(false)
            }
        }

        // Remove all observers
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Internal methods
    
    func addSubview(subview: BaseView) {
        subviews.append(subview)
    }
    
    func removeSubview(subview: BaseView) {
        subviews = subviews.filter { return $0 !== subview }
    }
    
    func viewControllerDidBecomeActive(active: Bool) {
        viewModel.active = active
    }
    
    // MARK: - Private methods
    
    // MARK: > NSNotificationCenter
    
    @objc private func applicationDidEnterBackground(notification: NSNotification) {
        viewControllerDidBecomeActive(false)
    }
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        viewControllerDidBecomeActive(true)
    }
}