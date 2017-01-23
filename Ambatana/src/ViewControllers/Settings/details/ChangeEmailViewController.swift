//
//  ChangeEmailViewController.swift
//  LetGo
//
//  Created by Nestor on 18/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import Foundation
import Result
import RxSwift

extension ChangeEmailViewController: ChangeEmailViewModelDelegate {}

class ChangeEmailViewController: BaseViewController, UITextFieldDelegate {
    
    private let customView: ChangeEmailView
    private let viewModel: ChangeEmailViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    init(with viewModel: ChangeEmailViewModel) {
        self.viewModel = viewModel
        self.customView = ChangeEmailView()
        
        super.init(viewModel: viewModel, nibName: nil)
        
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupAccessibilityIds()
        setupRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        customView.emailTextField.becomeFirstResponder()
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        customView.addToViewController(self, inView: view)
        setNavBarTitle(LGLocalizedString.changeEmailTitle)
        customView.emailTitleLabel.text = LGLocalizedString.changeEmailCurrentEmailLabel
        customView.emailLabel.text = viewModel.currentEmail
        customView.emailTextField.placeholder = LGLocalizedString.changeEmailFieldHint
        customView.emailTextField.delegate = self
        customView.saveButton.setTitle(LGLocalizedString.changeUsernameSaveButton, for: .normal)
        customView.saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        customView.saveButton.isEnabled = false
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        customView.emailLabel.accessibilityId = .changeEmailCurrentEmailLabel
        customView.emailTextField.accessibilityId = .changeEmailTextField
        customView.saveButton.accessibilityId = .changeEmailSendButton
    }
    
    private func setupRx() {
        customView.saveButton.rx.tap.subscribeNext { [weak self] in
            self?.viewModel.updateEmail()
        }.addDisposableTo(disposeBag)
        customView.emailTextField.rx.text.bindTo(viewModel.newEmail).addDisposableTo(disposeBag)
        viewModel.shouldAllowToContinue.bindTo(customView.saveButton.rx.isEnabled).addDisposableTo(disposeBag)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.updateEmail()
        return true
    }
}
