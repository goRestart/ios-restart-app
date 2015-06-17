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
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: RememberPasswordViewModel(), nibName: "RememberPasswordViewController")
    }
    
    required init(viewModel: RememberPasswordViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel.delegate = self
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        emailTextField.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor)
        emailButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor)
    }
    
    // MARK: - Actions
    
    @IBAction func resetPasswordButtonPressed(sender: AnyObject) {
        viewModel.resetPassword()
    }
    
    // MARK: - RememberPasswordViewModelDelegate
    
    func viewModel(viewModel: RememberPasswordViewModel, updateSendButtonEnabledState enabled: Bool) {
        resetPasswordButton.enabled = enabled
    }
    
    func viewModelDidStartResettingPassword(viewModel: RememberPasswordViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: RememberPasswordViewModel, didFinishResettingPasswordWithResult result: Result<Nil, UserPasswordResetServiceError>) {
        
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.showAutoFadingOutMessageAlert(NSLocalizedString("reset_password_successful", comment: "")) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            break
        case .Failure(let error):
            let message: String
            switch (error.value) {
            case .InvalidEmail:
                message = NSLocalizedString("reset_password_error_invalid_email", comment: "")
            case .UserNotFound:
                message = NSLocalizedString("reset_password_error_user_not_found_or_wrong_password", comment: "")
            case .Network:
                message = NSLocalizedString("error_connection_failed", comment: "")
            case .Internal:
                message = NSLocalizedString("reset_password_error_generic_error", comment: "")
            }
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion: completion)
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
        setText("", intoTextField: textField)
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let tag = textField.tag
        let nextView = view.viewWithTag(tag + 1)
        if let actualNextView = nextView {
            actualNextView.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        setText(text, intoTextField: textField)
        return false
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    func setupUI() {
        // Navigation bar
        let backButton = UIBarButtonItem(image: UIImage(named: "navbar_back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popBackViewController")
        navigationItem.leftBarButtonItem = backButton
//        navigationController?.interactivePopGestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
        
        // Appearance
        resetPasswordButton.setBackgroundImage(resetPasswordButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        resetPasswordButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        resetPasswordButton.layer.cornerRadius = 4
        
        // i18n
        title = NSLocalizedString("reset_password_title", comment: "")
        emailTextField.placeholder = NSLocalizedString("reset_password_email_field_placeholder", comment: "")
        resetPasswordButton.setTitle(NSLocalizedString("reset_password_send_button", comment: ""), forState: .Normal)
        
        // Tags
        emailTextField.tag = TextFieldTag.Email.rawValue
    }
    
    private func updateSendButtonEnabledState() {
        resetPasswordButton.enabled = count(emailTextField.text) > 0
    }
    
    private func setText(text: String, intoTextField textField: UITextField) {
        textField.text = text
        
        if let tag = TextFieldTag(rawValue: textField.tag) {
            switch (tag) {
            case .Email:
                viewModel.email = text
            }
        }
    }
}
