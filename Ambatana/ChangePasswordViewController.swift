//
//  ChangePasswordViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 19/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Result
import UIKit

class ChangePasswordViewController: UIViewController, UITextFieldDelegate, ChangePasswordViewModelDelegate {
    
    // outlets & buttons
    @IBOutlet weak var passwordTextfield: LGTextField!
    @IBOutlet weak var confirmPasswordTextfield: LGTextField!
    @IBOutlet weak var sendButton : UIButton!
    
    var viewModel : ChangePasswordViewModel!
    
    enum TextFieldTag: Int {
        case Password = 1000, ConfirmPassword
    }
    var lines : [CALayer] = []
    
    init() {
        self.viewModel = ChangePasswordViewModel()
        self.lines = []
        super.init(nibName: "ChangePasswordViewController", bundle: NSBundle.mainBundle())
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(passwordTextfield.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(confirmPasswordTextfield.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(confirmPasswordTextfield.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
        
    }
   
    @IBAction func sendChangePasswordButtonPressed(sender: AnyObject) {
        viewModel.changePassword()
    }
    
    // MARK: - TextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let textFieldText = textField.text {
            let text = (textFieldText as NSString).stringByReplacingCharactersInRange(range, withString: string)
            if let tag = TextFieldTag(rawValue: textField.tag) {
                switch (tag) {
                case .Password:
                    viewModel.password = text
                case .ConfirmPassword:
                    viewModel.confirmPassword = text
                }
            }
        }
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            switch (tag) {
            case .Password:
                viewModel.password = ""
            case .ConfirmPassword:
                viewModel.confirmPassword = ""
            }
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.passwordTextfield {
            self.confirmPasswordTextfield.becomeFirstResponder()
        } else if textField == self.confirmPasswordTextfield {
            viewModel.changePassword()
        }
        return false
    }
    
    // MARK : - ChangePasswordViewModelDelegate Methods
    
    func viewModelDidStartSendingPassword(viewModel: ChangePasswordViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: ChangePasswordViewModel, didFailValidationWithError error: UserSaveServiceError) {
        let message: String
        switch (error) {
        case .Network:
            message = LGLocalizedString.changePasswordSendErrorGeneric
        case .Internal, .InvalidUsername, .EmailTaken, .UsernameTaken:
            message = LGLocalizedString.changePasswordSendErrorGeneric
        case .InvalidPassword:
            message = String(format: LGLocalizedString.changePasswordSendErrorInvalidPasswordWithMax, Constants.passwordMinLength, Constants.passwordMaxLength)
        case .PasswordMismatch:
            message = LGLocalizedString.changePasswordSendErrorPasswordsMismatch
        }
        self.showAutoFadingOutMessageAlert(message)
    }
    
    func viewModel(viewModel: ChangePasswordViewModel, didFinishSendingPasswordWithResult result: UserSaveServiceResult) {
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                // clean fields
                self.passwordTextfield.text = ""
                self.confirmPasswordTextfield.text = ""

                self.showAutoFadingOutMessageAlert(LGLocalizedString.changePasswordSendOk) {
                    navigationController?.popViewControllerAnimated(true)
                }
            }
            break
        case .Failure(let error):
            let message: String
            switch (error) {
            case .Network:
                message = LGLocalizedString.commonErrorConnectionFailed
            case .Internal:
                message = LGLocalizedString.commonErrorConnectionFailed
            case .InvalidPassword:
                message = String(format: LGLocalizedString.changePasswordSendErrorInvalidPasswordWithMax, Constants.passwordMinLength, Constants.passwordMaxLength)
            case .PasswordMismatch:
                message = LGLocalizedString.changePasswordSendErrorPasswordsMismatch
            case .InvalidUsername, .EmailTaken, .UsernameTaken:
                // should never happen
                message = LGLocalizedString.changePasswordSendErrorGeneric
            }
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        dismissLoadingMessageAlert(completion)
    }
    
    func viewModel(viewModel: ChangePasswordViewModel, updateSendButtonEnabledState enabled: Bool) {
        sendButton.enabled = enabled
    }
    
    // MARK: Private methods
    
    private func setupUI() {
        
        // UI/UX & Appearance
        passwordTextfield.delegate = self
        passwordTextfield.tag = TextFieldTag.Password.rawValue
        passwordTextfield.tintColor = StyleHelper.textFieldTintColor

        confirmPasswordTextfield.delegate = self
        confirmPasswordTextfield.tag = TextFieldTag.ConfirmPassword.rawValue
        confirmPasswordTextfield.tintColor = StyleHelper.textFieldTintColor
        
        setLetGoNavigationBarStyle(LGLocalizedString.changePasswordTitle)
        
        sendButton.setTitle(LGLocalizedString.changePasswordTitle, forState: UIControlState.Normal)
        sendButton.setBackgroundImage(sendButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        sendButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        sendButton.setBackgroundImage(StyleHelper.highlightedRedButtonColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Highlighted)

        sendButton.layer.cornerRadius = 4
        sendButton.enabled = false
        
        // internationalization
        passwordTextfield.placeholder = LGLocalizedString.changePasswordNewPasswordFieldHint
        confirmPasswordTextfield.placeholder = LGLocalizedString.changePasswordConfirmPasswordFieldHint

        passwordTextfield.becomeFirstResponder()
    }
}
