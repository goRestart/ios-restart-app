//
//  ChangePasswordViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 19/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import UIKit

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {
    // outlets & buttons
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI/UX & Appearance
        passwordTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        setLetGoNavigationBarStyle(title: translate("change_password"))
        setLetGoRightButtonsWithImageNames(["actionbar_save"], andSelectors: ["changePassword"])
        
        // internationalization
        passwordTextfield.placeholder = translate("password")
        confirmPasswordTextfield.placeholder = translate("confirm_password")
    }
   
    func changePassword() {
        // safety checks
        if count(passwordTextfield.text) < kLetGoMinPasswordLength || count(confirmPasswordTextfield.text) < kLetGoMinPasswordLength { // min length not fulfilled
            showAutoFadingOutMessageAlert(translate("insert_valid_password"))
        } else if passwordTextfield.text != confirmPasswordTextfield.text { // passwords do not match.
            showAutoFadingOutMessageAlert(translate("passwords_dont_match"))
        } else {
            // dismiss keyboard
            self.view.resignFirstResponder()
            self.view.endEditing(true)
            
            if let myUser = MyUserManager.sharedInstance.myUser() {
                // change password
                showLoadingMessageAlert()
                
                myUser.password = passwordTextfield.text
                MyUserManager.sharedInstance.saveUser(myUser) { [weak self] (success: Bool, error: NSError?) in
                    if let strongSelf = self {
                        if success {
                            strongSelf.dismissLoadingMessageAlert(completion: { () -> Void in
                                // clean fields
                                strongSelf.passwordTextfield.text = ""
                                strongSelf.confirmPasswordTextfield.text = ""
                                // show alert message and pop back to settings after finished.
                                strongSelf.showAutoFadingOutMessageAlert(translate("password_successfully_changed"), completionBlock: { (_) -> Void in
                                    strongSelf.popBackViewController()
                                })
                                
                            })
                        } else {
                            strongSelf.dismissLoadingMessageAlert(completion: { () -> Void in
                                strongSelf.showAutoFadingOutMessageAlert(translate("error_changing_password"))
                            })
                        }
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
