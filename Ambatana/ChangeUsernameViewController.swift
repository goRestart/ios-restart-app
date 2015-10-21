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
    
    var viewModel : ChangeUsernameViewModel!
    
    var lines: [CALayer]
    
    init() {
        self.viewModel = ChangeUsernameViewModel()
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
    }
    
    override func viewWillAppear(animated: Bool) {
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
        lines.append(usernameTextfield.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(usernameTextfield.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
        
    }
    
    @IBAction func saveUsername(sender: AnyObject) {
        viewModel?.saveUsername()
    }
    
    func saveBarButtonPressed() {
        viewModel.saveUsername()
    }
    
    // MARK: - TextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let textFieldText = textField.text {
            let text = (textFieldText as NSString).stringByReplacingCharactersInRange(range, withString: string)
            viewModel.username = text
        }
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        viewModel.username = ""
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let textFieldText = textField.text {
            if viewModel.isValidUsername(textFieldText) {
                viewModel?.saveUsername()
                return true
            }
            else {
                self.showAutoFadingOutMessageAlert(String(format: NSLocalizedString("change_username_error_invalid_username", comment: ""), 2), time: 3.5)
                return false
            }
        } else {
            return false
        }
    }
    
    // MARK : - ChangeUsernameViewModelDelegate Methods
    
    func viewModelDidStartSendingUser(viewModel: ChangeUsernameViewModel) {
        showLoadingMessageAlert(NSLocalizedString("change_username_loading", comment: ""))
    }
    
    func viewModel(viewModel: ChangeUsernameViewModel, didFailValidationWithError error: UserSaveServiceError) {
        let message: String
        switch (error) {
        case .Network, .Internal, .InvalidPassword, .PasswordMismatch:
            message = NSLocalizedString("common_error_connection_failed", comment: "")
        case .EmailTaken:
            // should never happen
            message = NSLocalizedString("common_error_connection_failed", comment: "")
        case .InvalidUsername:
            message = String(format: NSLocalizedString("change_username_error_invalid_username", comment: ""), 2)
        case .UsernameTaken:
            message = String(format: NSLocalizedString("change_username_error_invalid_username_letgo", comment: ""), viewModel.username)
        }
        
        self.showAutoFadingOutMessageAlert(message)
    }
    
    func viewModel(viewModel: ChangeUsernameViewModel, didFinishSendingUserWithResult result: UserSaveServiceResult) {
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.showAutoFadingOutMessageAlert(NSLocalizedString("change_username_send_ok", comment: "")) {
                    navigationController?.popViewControllerAnimated(true)
                }
            }
            break
        case .Failure(let error):
            let message: String
            switch (error) {
            case .Network:
                message = NSLocalizedString("common_error_connection_failed", comment: "")
            case .Internal, .InvalidPassword, .PasswordMismatch:
                message = NSLocalizedString("common_error_connection_failed", comment: "")
            case .EmailTaken:
                // should never happen
                message = NSLocalizedString("common_error_connection_failed", comment: "")
            case .InvalidUsername:
                message = String(format: NSLocalizedString("change_username_error_invalid_username", comment: ""), 2)
            case .UsernameTaken:
                message = String(format: NSLocalizedString("change_username_error_invalid_username_letgo", comment: ""), viewModel.username)
            }
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion)
    }
    
    func viewModel(viewModel: ChangeUsernameViewModel, updateSaveButtonEnabledState enabled: Bool) {
        saveButton.enabled = enabled
    }

    
    func setupUI() {
        
        usernameTextfield.delegate = self

        setLetGoNavigationBarStyle(NSLocalizedString("change_username_title", comment: ""))
        
        usernameTextfield.placeholder = NSLocalizedString("change_username_field_hint", comment: "")
        usernameTextfield.text = viewModel.username
        
        saveButton.setTitle(NSLocalizedString("change_username_save_button", comment: ""), forState: .Normal)
        saveButton.setBackgroundImage(saveButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        saveButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        saveButton.setBackgroundImage(StyleHelper.highlightedRedButtonColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Highlighted)

        saveButton.layer.cornerRadius = 4
        saveButton.enabled = false
    }
}