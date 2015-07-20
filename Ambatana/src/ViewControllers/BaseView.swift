//
//  BaseView.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class BaseView: UIView {

    private var viewModel: BaseViewModel!
    
    // MARK: Lifecycle
    
    init(viewModel: BaseViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }

    init(viewModel: BaseViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: aDecoder)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func viewDidBecomeActive(active: Bool) {
        viewModel.active = active
    }
    
    // MARK: - Private methods
    
    // MARK: > NSNotificationCenter
    
    @objc private func applicationDidEnterBackground(notification: NSNotification) {
        viewDidBecomeActive(false)
    }
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        viewDidBecomeActive(true)
    }
}
