//
//  UserPhoneVerificationCountryPickerViewController.swift
//  LetGo
//
//  Created by Sergi Gracia on 05/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

final class UserPhoneVerificationCountryPickerViewController: BaseViewController {

    private let viewModel: UserPhoneVerificationCountryPickerViewModel

    init(viewModel: UserPhoneVerificationCountryPickerViewModel) {
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

    }

    private func setupRx() {

    }
}
