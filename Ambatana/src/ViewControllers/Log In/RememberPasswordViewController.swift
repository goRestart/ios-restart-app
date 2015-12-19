//
//  RememberPasswordViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import UIKit

class RememberPasswordViewController: BaseViewController, RememberPasswordViewModelDelegate, UITextFieldDelegate {

    // Constants & enum
    enum TextFieldTag: Int {
        case Email = 1000
    }
    
    // ViewModel
    var viewModel: RememberPasswordViewModel!
    
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    @IBOutlet weak var instructionsLabel : UILabel!
    
    // > Helper
    var lines: [CALayer]
    
    // MARK: - Lifecycle
    
    init(source: EventParameterLoginSourceValue, email: String) {
        self.viewModel = RememberPasswordViewModel(source: source, email: email)
        self.lines = []
        super.init(viewModel: viewModel, nibName: "RememberPasswordViewController")
        self.viewModel.delegate = self
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        emailTextField.becomeFirstResponder()
        emailTextField.tintColor = StyleHelper.textFieldTintColor
        
        // update the textfield with the e-mail from previous view
        emailTextField.text = viewModel.email
        updateViewModelText(viewModel.email, fromTextFieldTag: emailTextField.tag)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(emailButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
    }
    
    // MARK: - Actions
    
    @IBAction func resetPasswordButtonPressed(sender: AnyObject) {
        viewModel.resetPassword()
    }
    
    // MARK: - RememberPasswordViewModelDelegate
    
    func viewModel(viewModel: RememberPasswordViewModel, updateSendButtonEnabledState enabled: Bool) {
        resetPasswordButton.enabled = enabled
        resetPasswordButton.alpha = enabled ? 1 : StyleHelper.disabledButtonAlpha
    }
    
    func viewModelDidStartResettingPassword(viewModel: RememberPasswordViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: RememberPasswordViewModel, didFinishResettingPasswordWithResult
        result: Result<Void, RememberPasswordError>) {
        
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.showAutoFadingOutMessageAlert(String(format: LGLocalizedString.resetPasswordSendOk, viewModel.email)) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            break
        case .Failure(let error):
            let message: String
            let errorDescription: EventParameterLoginError
            switch (error) {
            case .Api(let apiError):
                switch apiError {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                    errorDescription = .Network
                case .NotFound:
                    message = String(format: LGLocalizedString.resetPasswordSendErrorUserNotFoundOrWrongPassword, viewModel.email)
                    errorDescription = .NotFound
                case .Forbidden, .Internal:
                    message = LGLocalizedString.resetPasswordSendErrorGeneric
                    errorDescription = .Internal
                }
            case .Internal:
                message = LGLocalizedString.resetPasswordSendErrorGeneric
                errorDescription = .Internal
            case .InvalidEmail:
                message = LGLocalizedString.resetPasswordSendErrorInvalidEmail
                errorDescription = .InvalidEmail
            }
            
            viewModel.resetPasswordFailedWithError(errorDescription)
            
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .Email:
                iconImageView = emailIconImageView
            }
            iconImageView.highlighted = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .Email:
                iconImageView = emailIconImageView
            }
            iconImageView.highlighted = false
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        updateViewModelText("", fromTextFieldTag: textField.tag)
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let tag = textField.tag
        let nextView = view.viewWithTag(tag + 1)
        if let actualNextView = nextView {
            actualNextView.becomeFirstResponder()
        }
        else {
            viewModel.resetPassword()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let textFieldText = textField.text {
            let text = (textFieldText as NSString).stringByReplacingCharactersInRange(range, withString: string)
            updateViewModelText(text, fromTextFieldTag: textField.tag)
        }
        return true
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    func setupUI() {
        // Appearance
        resetPasswordButton.setBackgroundImage(resetPasswordButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        resetPasswordButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        resetPasswordButton.setBackgroundImage(StyleHelper.highlightedRedButtonColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Highlighted)

        resetPasswordButton.layer.cornerRadius = 4
        
        // i18n
        setLetGoNavigationBarStyle(LGLocalizedString.resetPasswordTitle)
        emailTextField.placeholder = LGLocalizedString.resetPasswordEmailFieldHint
        resetPasswordButton.setTitle(LGLocalizedString.resetPasswordSendButton, forState: .Normal)
        instructionsLabel.text = LGLocalizedString.resetPasswordInstructions
        
        // Tags
        emailTextField.tag = TextFieldTag.Email.rawValue
    }
    
    private func updateSendButtonEnabledState() {
        if let email = emailTextField.text {
            resetPasswordButton.enabled = email.characters.count > 0
        } else {
            resetPasswordButton.enabled = false
            resetPasswordButton.alpha = StyleHelper.disabledButtonAlpha
        }
    }
    
    // MARK: > Helper
    
    private func updateViewModelText(text: String, fromTextFieldTag tag: Int) {
        if let tag = TextFieldTag(rawValue: tag) {
            switch (tag) {
            case .Email:
                viewModel.email = text
            }
        }
    }
}
