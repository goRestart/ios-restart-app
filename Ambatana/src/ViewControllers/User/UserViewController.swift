//
//  UserViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class UserViewController: BaseViewController {
    private var viewModel : UserViewModel

    
    // MARK: - Lifecycle

    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "UserViewController")

        self.viewModel.delegate = self

        automaticallyAdjustsScrollViewInsets = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


// MARK: - UserViewModelDelegate

extension UserViewController: UserViewModelDelegate {

}
