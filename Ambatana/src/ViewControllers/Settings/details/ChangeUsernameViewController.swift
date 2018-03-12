//
//  ChangeUserNameViewController.swift
//  LetGo
//
//  Created by Dídac on 21/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import UIKit


class ChangeUsernameViewController: BaseViewController, UITextFieldDelegate, ChangeUsernameViewModelDelegate {

    // outlets & buttons
    @IBOutlet weak var usernameTextfield: LGTextField!
    @IBOutlet weak var saveButton: UIButton!
    
    let viewModel: ChangeUsernameViewModel
    
    var lines: [CALayer]
    
    init(vm: ChangeUsernameViewModel) {
        self.viewModel = vm
        self.lines = []
        super.init(viewModel: viewModel, nibName: "ChangeUsernameViewController")
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAccessibilityIds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameTextfield.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(usernameTextfield.addTopBorderWithWidth(1, color: UIColor.lineGray))
        lines.append(usernameTextfield.addBottomBorderWithWidth(1, color: UIColor.lineGray))
        
    }
    
    @IBAction func saveUsername(_ sender: AnyObject) {
        viewModel.saveUsername()
    }
    
    func saveBarButtonPressed() {
        viewModel.saveUsername()
    }
    
    // MARK: - TextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.containsEmoji else { return false }
        guard let text = textField.text else { return false }
        let newLength = text.count + string.count - range.length
        let removing = text.count > newLength
        if !removing && newLength > Constants.maxUserNameLength { return false }

        let updatedText =  (text as NSString).replacingCharacters(in: range, with: string)
        viewModel.username = updatedText
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.username = ""
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let textFieldText = textField.text {
            if viewModel.isValidUsername(textFieldText) {
                viewModel.saveUsername()
                return true
            }
            else {
                self.showAutoFadingOutMessageAlert(
                    LGLocalizedString.changeUsernameErrorInvalidUsername(Constants.fullNameMinLength), time: 3.5)
                return false
            }
        } else {
            return false
        }
    }
    
    // MARK : - ChangeUsernameViewModelDelegate Methods
    
    func viewModelDidStartSendingUser(_ viewModel: ChangeUsernameViewModel) {
        showLoadingMessageAlert(LGLocalizedString.changeUsernameLoading)
    }
    
    func viewModel(_ viewModel: ChangeUsernameViewModel, didFailValidationWithError error: ChangeUsernameError) {
        let message: String
        switch (error) {
        case .network, .internalError, .notFound, .unauthorized:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .invalidUsername:
            message = LGLocalizedString.changeUsernameErrorInvalidUsername(Constants.fullNameMinLength)
        case .usernameTaken:
            message = LGLocalizedString.changeUsernameErrorInvalidUsernameLetgo(viewModel.username)
        }
        
        self.showAutoFadingOutMessageAlert(message)
    }
    
    func viewModel(_ viewModel: ChangeUsernameViewModel, didFinishSendingUserWithResult
        result: Result<MyUser, ChangeUsernameError>) {
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .success:
            completion = {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.changeUsernameSendOk) { [weak self] in
                    self?.viewModel.userNameSaved()
                }
            }
            break
        case .failure(let error):
            let message: String
            switch (error) {
            case .network, .internalError, .notFound, .unauthorized:
                message = LGLocalizedString.commonErrorConnectionFailed
            case .invalidUsername:
                message = LGLocalizedString.changeUsernameErrorInvalidUsername(Constants.fullNameMinLength)
            case .usernameTaken:
                message = LGLocalizedString.changeUsernameErrorInvalidUsernameLetgo(viewModel.username)
            }
            completion = { [weak self] in
                self?.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion)
    }
    
    func viewModel(_ viewModel: ChangeUsernameViewModel, updateSaveButtonEnabledState enabled: Bool) {
        saveButton.isEnabled = enabled
    }

    
    func setupUI() {
        
        usernameTextfield.delegate = self

        setNavBarTitle(LGLocalizedString.changeUsernameTitle)
        
        usernameTextfield.placeholder = LGLocalizedString.changeUsernameFieldHint
        usernameTextfield.text = viewModel.username
        
        saveButton.setTitle(LGLocalizedString.changeUsernameSaveButton, for: .normal)
        saveButton.setStyle(.primary(fontSize: .big))
        saveButton.isEnabled = false
    }

    private func setupAccessibilityIds() {
        usernameTextfield.set(accessibilityId: .changeUsernameNameField)
        saveButton.set(accessibilityId: .changeUsernameSendButton)
    }
}
