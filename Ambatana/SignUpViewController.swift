//
//  SignUpViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 16/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Parse
import UIKit

/* Error codes for Parse signup process. This enum exists to show the user a proper error message when signing up goes wrong.
UsernameMissing	200	Error code indicating that the username is missing or empty.
PasswordMissing	201	Error code indicating that the password is missing or empty.
UsernameTaken	202	Error code indicating that the username has already been taken.
EmailTaken	203	Error code indicating that the email has already been taken.
EmailMissing	204	Error code indicating that the email is missing, but must be specified.
EmailNotFound	205	Error code indicating that a user with the specified email was not found.
*/
enum ParseSignupErrorCodes: Int {
    case UsernameMissing = 200, PasswordMissing = 201, UsernameTaken = 202, EmailTaken = 203, EmailMissing = 204, EmailNotFound = 205
    func errorMessageForCode() -> String {
        if self == .UsernameTaken { return translate("user_already_exists") }
        else { return translate("some_fields_missing") }
    }
}

class SignUpViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {
    // outlets && buttons
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var sellAndBuyLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var orUseLabel: UILabel!
    @IBOutlet weak var connectWithFacebookButton: UIButton!
    @IBOutlet weak var alreadyHaveAnAccountLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    
    // var data
    var delegate: LoginAndSigninDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signUpButton.layer.borderWidth = 2.0
        signUpButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        nameTextfield.delegate = self
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        
        // internationalization
        signUpLabel.text = translate("signup_start_making_money")
        sellAndBuyLabel.text = translate("sell_buy_with_chat")
        fullNameLabel.text = translate("full_name")
        emailLabel.text = translate("email")
        passwordLabel.text = translate("password")
        passwordTextfield.placeholder = translate("more_six_characters")
        signUpButton.setTitle(translate("signup"), forState: .Normal)
        orUseLabel.text = translate("or_use")
        connectWithFacebookButton.setTitle(translate("connect_with_facebook"), forState: .Normal)
        alreadyHaveAnAccountLabel.text = translate("already_have_account")
        signInButton.setTitle(translate("signin"), forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameScreenPublic, eventParameters: [kLetGoTrackingParameterNameScreenName: "signup-email"])
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
    
    @IBAction func signUp(sender: AnyObject) {
        // sanity checks
        if count(self.nameTextfield.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) < 1 {
            showAutoFadingOutMessageAlert(translate("insert_valid_name"))
            return
        }
        if !self.emailTextfield.text.isEmail() {
            showAutoFadingOutMessageAlert(translate("insert_valid_email"))
            return
        }
        if count(self.passwordTextfield.text) < kLetGoMinPasswordLength {
            showAutoFadingOutMessageAlert(translate("insert_valid_password"))
            return
        }
        
        // sign up
        self.view.resignFirstResponder()
        self.view.endEditing(true)
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        self.view.userInteractionEnabled = false
        
        let user = PFUser()
        user.username = self.emailTextfield.text!
        user.email = self.emailTextfield.text!
        user.password = self.passwordTextfield.text!
        user["username_public"] = self.nameTextfield.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            if success { // successfully signed up with email
                TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameSignupEmail, eventParameters: [kLetGoTrackingParameterNameUserEmail: user.email!])
                if iOSVersionAtLeast("8.0") {
                    let alert = UIAlertController(title: translate("success"), message: translate("user_created_successfully"), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: translate("login_now"), style: .Default, handler: { (alertAction) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else { // fallback to iOS7 AlertView style
                    let alert = UIAlertView(title: translate("success"), message: translate("user_created_successfully"), delegate: self, cancelButtonTitle: translate("login_now"))
                    alert.show()
                }
            } else {
                // try to return a friendly error message based on Parse signup response code.
                if let errorCode = ParseSignupErrorCodes(rawValue: error!.code) {
                    self.showAutoFadingOutMessageAlert(translate("error_creating_user") + " " + errorCode.errorMessageForCode())
                } else { self.showAutoFadingOutMessageAlert(translate("error_creating_user")) }
            }
            self.view.userInteractionEnabled = true
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func useFacebook(sender: AnyObject) {
        self.delegate?.loginDelegateConnectWithFacebook?() ?? self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signIn(sender: AnyObject) {
        self.delegate?.loginDelegateSignIn?() ?? self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.nameTextfield {
            emailTextfield.becomeFirstResponder()
        } else if textField == self.emailTextfield {
            passwordTextfield.becomeFirstResponder()
        } else if textField == self.passwordTextfield {
            passwordTextfield.resignFirstResponder()
            self.view.endEditing(true)
            self.signUp(signUpButton)
        }
        
        return false
    }
    
    // MARK: - UX
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
