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
        lines.append(usernameTextfield.addTopBorderWithWidth(1, color: UIColor.lineGray))
        lines.append(usernameTextfield.addBottomBorderWithWidth(1, color: UIColor.lineGray))
        
    }
    
    @IBAction func saveUsername(sender: AnyObject) {
        viewModel?.saveUsername()
    }
    
    func saveBarButtonPressed() {
        viewModel.saveUsername()
    }
    
    // MARK: - TextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard !string.hasEmojis() else { return false }
        guard let text = textField.text else { return false }
        let newLength = text.characters.count + string.characters.count - range.length
        let removing = text.characters.count > newLength
        if !removing && newLength > Constants.maxUserNameLength { return false }

        let updatedText =  (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        viewModel.username = updatedText
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
                self.showAutoFadingOutMessageAlert(
                    LGLocalizedString.changeUsernameErrorInvalidUsername(Constants.fullNameMinLength), time: 3.5)
                return false
            }
        } else {
            return false
        }
    }
    
    // MARK : - ChangeUsernameViewModelDelegate Methods
    
    func viewModelDidStartSendingUser(viewModel: ChangeUsernameViewModel) {
        showLoadingMessageAlert(LGLocalizedString.changeUsernameLoading)
    }
    
    func viewModel(viewModel: ChangeUsernameViewModel, didFailValidationWithError error: ChangeUsernameError) {
        let message: String
        switch (error) {
        case .Network, .Internal, .NotFound, .Unauthorized:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .InvalidUsername:
            message = LGLocalizedString.changeUsernameErrorInvalidUsername(Constants.fullNameMinLength)
        case .UsernameTaken:
            message = LGLocalizedString.changeUsernameErrorInvalidUsernameLetgo(viewModel.username)
        }
        
        self.showAutoFadingOutMessageAlert(message)
    }
    
    func viewModel(viewModel: ChangeUsernameViewModel, didFinishSendingUserWithResult
        result: Result<MyUser, ChangeUsernameError>) {
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.changeUsernameSendOk) { [weak self] in
                    self?.navigationController?.popViewControllerAnimated(true)
                }
            }
            break
        case .Failure(let error):
            let message: String
            switch (error) {
            case .Network, .Internal, .NotFound, .Unauthorized:
                message = LGLocalizedString.commonErrorConnectionFailed
            case .InvalidUsername:
                message = LGLocalizedString.changeUsernameErrorInvalidUsername(Constants.fullNameMinLength)
            case .UsernameTaken:
                message = LGLocalizedString.changeUsernameErrorInvalidUsernameLetgo(viewModel.username)
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

        setNavBarTitle(LGLocalizedString.changeUsernameTitle)
        
        usernameTextfield.placeholder = LGLocalizedString.changeUsernameFieldHint
        usernameTextfield.text = viewModel.username
        
        saveButton.setTitle(LGLocalizedString.changeUsernameSaveButton, forState: .Normal)
        saveButton.setBackgroundImage(saveButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        saveButton.setBackgroundImage(UIColor.primaryColorDisabled.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        saveButton.setBackgroundImage(UIColor.primaryColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)), forState: .Highlighted)

        saveButton.layer.cornerRadius = 4
        saveButton.enabled = false
    }
}