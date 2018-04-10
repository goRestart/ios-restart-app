//
//  UserPhoneVerificationCodeInputViewController.swift
//  LetGo
//
//  Created by Sergi Gracia on 05/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

final class UserPhoneVerificationCodeInputViewController: BaseViewController {

    private let viewModel: UserPhoneVerificationCodeInputViewModel

    init(viewModel: UserPhoneVerificationCodeInputViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }

    private func setupUI() {
        // FIXME: implement this
    }

    private func setupRx() {
        // FIXME: implement this
    }
}
