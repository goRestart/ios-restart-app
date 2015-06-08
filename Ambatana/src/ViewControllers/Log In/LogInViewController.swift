//
//  LogInViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class LogInViewController: BaseViewController {

    // ViewModel
    var viewModel: LogInViewModel!
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: LogInViewModel(), nibName: "LogInViewController")
    }
    
    required init(viewModel: LogInViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
