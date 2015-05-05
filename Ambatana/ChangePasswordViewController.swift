//
//  ChangePasswordViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 19/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Parse
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
        setLetGoNavigationBarStyle(title: translate("change_password"), includeBackArrow: true)
        setLetGoRightButtonsWithImageNames(["actionbar_save"], andSelectors: ["changePassword"])
        
        // internationalization
        passwordTextfield.placeholder = translate("password")
        confirmPasswordTextfield.placeholder = translate("confirm_password")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameScreenPrivate, eventParameters: [kLetGoTrackingParameterNameScreenName: "change-password"])
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            // change password
            showLoadingMessageAlert()
            PFUser.currentUser()!.password = passwordTextfield.text
            PFUser.currentUser()!.saveInBackgroundWithBlock({ [weak self] (success, error) -> Void in
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
            })
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
