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
    
    // MARK: Lifecycle
    
    init(viewModel: BaseViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.active = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationDidEnterBackground:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationWillEnterForeground:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Private methods
    
    // MARK: > NSNotificationCenter
    
    @objc private func applicationDidEnterBackground(notification: NSNotification) {
        viewModel.active = false
    }
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        viewModel.active = true
    }
}