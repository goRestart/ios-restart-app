//
//  LoginByEmailViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 16/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class LoginByEmailViewController: UIViewController, UITextFieldDelegate {
    // outlets && buttons
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var recoverLostPasswordButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var orUseLabel: UILabel!
    @IBOutlet weak var connectWithFacebookButton: UIButton!

    // data
    var delegate: LoginAndSigninDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signInButton.layer.borderWidth = 2.0
        signInButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        
        // internationalization
        signInButton.setTitle(translate("signin"), forState: .Normal)
        emailLabel.text = translate("email")
        passwordLabel.text = translate("password")
        recoverLostPasswordButton.setTitle(translate("recover_lost_password"), forState: .Normal)
        createAccountButton.setTitle(translate("create_account"), forState: .Normal)
        passwordTextfield.placeholder = translate("insert_your_password")
        orUseLabel.text = translate("or_use")
        connectWithFacebookButton.setTitle(translate("connect_with_facebook"), forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Button actions
    
    @IBAction func signIn(sender: AnyObject) {
        // sanity checks
        if !self.emailTextfield.text.isEmail() {
            showAutoFadingOutMessageAlert(translate("insert_valid_email"))
            return
        }
        if countElements(self.passwordTextfield.text) < 6 {
            showAutoFadingOutMessageAlert(translate("insert_valid_password"))
            return
        }
        
        // sign up
        self.view.resignFirstResponder()
        self.view.endEditing(true)
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        self.view.userInteractionEnabled = false
        
        PFUser.logInWithUsernameInBackground(self.emailTextfield.text!, password: self.passwordTextfield.text!) { (user, error) -> Void in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            if error == nil && user != nil {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.showAutoFadingOutMessageAlert(translate("incorrect_credentials"))
            }
            self.view.userInteractionEnabled = true
        }
    }
    
    
    @IBAction func recoverLostPassword(sender: AnyObject) {
        if self.emailTextfield != nil && self.emailTextfield.text.isEmail() {
            self.delegate?.loginDelegateRecoverPassword?(self.emailTextfield.text!) ?? self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.showAutoFadingOutMessageAlert(translate("insert_valid_email"));
        }
    }
    
    @IBAction func createAccount(sender: AnyObject) {
        self.delegate?.loginDelegateSignUp?() ?? self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func connectWithFacebook(sender: AnyObject) {
        self.delegate?.loginDelegateConnectWithFacebook?() ?? self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.emailTextfield {
            self.passwordTextfield.becomeFirstResponder()
        } else if textField == self.passwordTextfield {
            textField.resignFirstResponder()
            self.view.endEditing(true)
            self.signIn(self.signInButton)
        }
        return false
    }
    
    // MARK: - UX
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
