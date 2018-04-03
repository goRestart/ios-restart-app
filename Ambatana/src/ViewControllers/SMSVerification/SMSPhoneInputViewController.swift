//
//  SMSPhoneInputViewController.swift
//  LetGo
//
//  Created by Sergi Gracia on 03/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift
import RxCocoa

class SMSPhoneInputViewController: BaseViewController {

    private let viewModel: SMSPhoneInputViewModel

    struct Layout {

    }

    init(viewModel: SMSPhoneInputViewModel) {
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
