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

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {
    // outlets & buttons
    @IBOutlet weak var passwordTextfield: LGTextField!
    @IBOutlet weak var confirmPasswordTextfield: LGTextField!
    @IBOutlet weak var sendButton : UIButton!
    
    var lines : [CALayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI/UX & Appearance
        passwordTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        setLetGoNavigationBarStyle(title: NSLocalizedString("change_password_title", comment: ""))
//        setLetGoRightButtonsWithImageNames(["actionbar_save"], andSelectors: ["changePassword"])
        
        sendButton.setTitle(NSLocalizedString("change_password_title", comment: ""), forState: UIControlState.Normal)
        sendButton.layer.cornerRadius = 4
        
        // internationalization
        passwordTextfield.placeholder = NSLocalizedString("change_password_new_password_field_hint", comment: "")
        confirmPasswordTextfield.placeholder = NSLocalizedString("change_password_confirm_password_field_hint", comment: "")
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
        changePassword()
    }
    
    func changePassword() {
        // safety checks
        if count(passwordTextfield.text) < Constants.passwordMinLength || count(confirmPasswordTextfield.text) < Constants.passwordMinLength { // min length not fulfilled
            showAutoFadingOutMessageAlert(String(format: NSLocalizedString("change_password_send_error_invalid_password", comment: ""), Constants.passwordMinLength))
        } else if passwordTextfield.text != confirmPasswordTextfield.text { // passwords do not match.
            showAutoFadingOutMessageAlert(NSLocalizedString("change_password_send_error_passwords_mismatch", comment: ""))
        } else {
            // dismiss keyboard
            self.view.resignFirstResponder()
            self.view.endEditing(true)
            
            showLoadingMessageAlert()
            
            MyUserManager.sharedInstance.updatePassword(passwordTextfield.text) { [weak self] (result: Result<User, UserSaveServiceError>) in
                if let strongSelf = self {
                    // Success
                    if let user = result.value {
                        strongSelf.dismissLoadingMessageAlert(completion: { () -> Void in
                            // clean fields
                            strongSelf.passwordTextfield.text = ""
                            strongSelf.confirmPasswordTextfield.text = ""
                            // show alert message and pop back to settings after finished.
                            strongSelf.showAutoFadingOutMessageAlert(NSLocalizedString("change_password_send_ok", comment: ""), completionBlock: { (_) -> Void in
                                strongSelf.popBackViewController()
                            })
                        })
                    }
                    // Error
                    else {
                        strongSelf.dismissLoadingMessageAlert(completion: { () -> Void in
                            strongSelf.showAutoFadingOutMessageAlert(NSLocalizedString("change_password_send_error_generic", comment: ""))
                        })
                    }
                }
            }
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.passwordTextfield {
            self.confirmPasswordTextfield.becomeFirstResponder()
        } else if textField == self.confirmPasswordTextfield {
            changePassword()
        }
        return false
    }
}
