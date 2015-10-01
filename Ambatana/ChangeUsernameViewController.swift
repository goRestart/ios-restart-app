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
    
    required init(coder: NSCoder) {
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
        let text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        viewModel.username = text
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        viewModel.username = ""
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if viewModel.isValidUsername(textField.text) {
            viewModel?.saveUsername()
            return true
        }
        else {
            self.showAutoFadingOutMessageAlert(String(format: NSLocalizedString("change_username_error_invalid_username", comment: ""), 2), time: 3.5)
            return false
        }
    }
    
    // MARK : - ChangeUsernameViewModelDelegate Methods
    
    func viewModelDidStartSendingUser(viewModel: ChangeUsernameViewModel) {
        showLoadingMessageAlert(customMessage: NSLocalizedString("change_username_loading", comment: ""))
    }
    
    func viewModel(viewModel: ChangeUsernameViewModel, didFailValidationWithError error: UserSaveServiceError) {
        self.showAutoFadingOutMessageAlert(String(format: NSLocalizedString("change_username_error_invalid_username", comment: ""), 2))
    }
    
    func viewModel(viewModel: ChangeUsernameViewModel, didFinishSendingUserWithResult result: Result<User, UserSaveServiceError>) {
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
            switch (error.value) {
            case .Network:
                message = NSLocalizedString("common_error_connection_failed", comment: "")
            case .Internal, .InvalidPassword, .PasswordMismatch:
                message = NSLocalizedString("common_error_connection_failed", comment: "")
            case .EmailTaken:
                // should never happen
                message = NSLocalizedString("common_error_connection_failed", comment: "")
            case .InvalidUsername:
                message = String(format: NSLocalizedString("change_username_error_invalid_username", comment: ""), 2)
            }
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion: completion)
    }
    
    func viewModel(viewModel: ChangeUsernameViewModel, updateSaveButtonEnabledState enabled: Bool) {
        saveButton.enabled = enabled
    }

    
    func setupUI() {
        
        usernameTextfield.delegate = self

        setLetGoNavigationBarStyle(title: NSLocalizedString("change_username_title", comment: ""))
        
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