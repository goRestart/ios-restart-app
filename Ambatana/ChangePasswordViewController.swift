//
//  ChangePasswordViewController.swift
//  Ambatana
//
//  Created by Nacho on 19/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    // outlets & buttons
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI/UX & Appearance
        setAmbatanaNavigationBarStyle(title: translate("change_password"), includeBackArrow: true)
        setAmbatanaRightButtonsWithImageNames(["actionbar_save"], andSelectors: ["changePassword"])
        
        // internationalization
        passwordTextfield.placeholder = translate("password")
        confirmPasswordTextfield.placeholder = translate("confirm_password")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changePassword() {
        // safety checks
        if countElements(passwordTextfield.text) < kAmbatanaMinPasswordLength || countElements(confirmPasswordTextfield.text) < kAmbatanaMinPasswordLength { // min length not fulfilled
            showAutoFadingOutMessageAlert(translate("insert_valid_password"))
        } else if passwordTextfield.text != confirmPasswordTextfield.text { // passwords do not match.
            showAutoFadingOutMessageAlert(translate("passwords_dont_match"))
        } else {
            // dismiss keyboard
            self.view.resignFirstResponder()
            self.view.endEditing(true)
            
            // change password
            showLoadingMessageAlert()
            PFUser.currentUser().password = passwordTextfield.text
            PFUser.currentUser().saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        // clean fields
                        self.passwordTextfield.text = ""
                        self.confirmPasswordTextfield.text = ""
                        // show alert message and pop back to settings after finished.
                        self.showAutoFadingOutMessageAlert(translate("password_successfully_changed"), completionBlock: { (_) -> Void in
                            self.popBackViewController()
                        })
                    })
                } else {
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        self.showAutoFadingOutMessageAlert(translate("error_changing_password"))
                    })
                }
            })
        }
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
