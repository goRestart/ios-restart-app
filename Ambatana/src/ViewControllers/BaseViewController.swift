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
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
    }
}