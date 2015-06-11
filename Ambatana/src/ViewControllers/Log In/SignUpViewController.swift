//
//  SignUpViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

class SignUpViewController: BaseViewController {
    
    // ViewModel
    var viewModel: SignUpViewModel!
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: SignUpViewModel(), nibName: "SignUpViewController")
    }
    
    required init(viewModel: SignUpViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        
        // Navigation bar
        let backButton = UIBarButtonItem(image: UIImage(named: "navbar_back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popBackViewController")
        navigationItem.leftBarButtonItem = backButton
        navigationController?.interactivePopGestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    override func popBackViewController() {
//        
//    }
}
