//
//  SignUpStep2ViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

final class SignUpStep2ViewController: BaseViewController {
    private var viewModel: SignUpStep2ViewModel


    // MARK: - Lifecycle

    init(viewModel: SignUpStep2ViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
