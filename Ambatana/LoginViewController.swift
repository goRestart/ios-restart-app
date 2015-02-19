//
//  ViewController.swift
//  Ambatana
//
//  Created by Nacho on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

@objc protocol LoginAndSigninDelegate {
    optional func loginDelegateSignIn()
    optional func loginDelegateSignUp()
    optional func loginDelegateConnectWithFacebook()
    optional func loginDelegateRecoverPassword(email: String)
}

class LoginViewController: UIViewController, LoginAndSigninDelegate {
    // outlets && buttons
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var ambatanaLoginLabel: UILabel!
    @IBOutlet weak var orUseEmailLabel: UILabel!
    
    // vars & data
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // internationalization
        ambatanaLoginLabel.text = translate("fun_unique_way")
        facebookLoginButton.setTitle(translate("connect_with_facebook"), forState: .Normal)
        signupButton.setTitle(translate("signup"), forState: .Normal)
        loginButton.setTitle(translate("login"), forState: .Normal)
        orUseEmailLabel.text = translate("or_use_your_email").uppercaseString
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // UI
        self.view.alpha = 0.0
        
        // register for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "oauthSessionExpired:", name: kAmbatanaSessionInvalidatedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "authenticationError:", name: kAmbatanaInvalidCredentialsNotification, object: nil)
        
        // check current login status
        if (PFUser.currentUser() != nil) { // && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser())) {
            ConfigurationManager.sharedInstance.loadDataFromCurrentUser()
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(0.01 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("StartApp", sender: nil)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.alpha = 1.0
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - reacting to login notifications
    
    func oauthSessionExpired(notification: NSNotification) {
        let alert = UIAlertController(title: translate("session_expired"), message: translate("your_session_has_expired"), preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: translate("ok"), style:.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    func authenticationError(notification: NSNotification) {
        let alert = UIAlertController(title: translate("authentication_error"), message: translate("unable_access_system"), preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: translate("ok"), style:.Default, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Button actions
    
    @IBAction func connectWithFacebook(sender: UIButton) {
        let permissionsArray = ["user_about_me", "user_location", "email", "public_profile"]
        PFFacebookUtils.logInWithPermissions(permissionsArray, block: { (user, error) -> Void in
            if user != nil { // login succeed
                if user.isNew { // if we have just created the new user we need to set the Facebook
                    // load facebook data into profile.
                    println("User created for the first time by Facebook.")
                    ConfigurationManager.sharedInstance.loadInitialFacebookProfileData()
                } else { // load configuration from previous user
                    ConfigurationManager.sharedInstance.loadDataFromCurrentUser()
                }
                
                self.performSegueWithIdentifier("StartApp", sender: nil)
            } else { // error login
                let alert = UIAlertController(title: translate("unable_login"), message: translate("login_canceled"), preferredStyle:.Alert)
                alert.addAction(UIAlertAction(title: translate("ok"), style:.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
        
        
    }
    
    @IBAction func signUp(sender: UIButton) {
        // DO NOTHING.
    }
    
    @IBAction func login(sender: UIButton) {
        // DO NOTHING.
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let lvc = segue.destinationViewController as? LoginByEmailViewController {
            lvc.delegate = self
        } else if let suvc = segue.destinationViewController as? SignUpViewController {
            suvc.delegate = self
        }
    }
    
    // MARK: - Login and SignIn delegate methods
    
    func loginDelegateSignIn() {
        println("Going to sign in!")
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.performSegueWithIdentifier("LoginByEmail", sender: nil)
        })
    }
    
    func loginDelegateSignUp() {
        println("Going to sign up!")
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.performSegueWithIdentifier("SignUp", sender: nil)
        })
    }
    
    func loginDelegateConnectWithFacebook() {
        println("Connecting with facebook!")
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.connectWithFacebook(self.facebookLoginButton)
        })
    }
    
    func loginDelegateRecoverPassword(email: String) {
        println("Recovery password")
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            let alert = UIAlertController(title: translate("password_recovery"), message: translate("send_recovery_email_question"), preferredStyle:.Alert)
            alert.addAction(UIAlertAction(title: translate("cancel"), style:.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: translate("ok"), style: .Default, handler: { (alertAction) -> Void in
                PFUser.requestPasswordResetForEmailInBackground(email, block: { (success, error) -> Void in
                    if success {
                        self.showAutoFadingOutMessageAlert(translate("password_recovery_email_sent"))
                    } else {
                        self.showAutoFadingOutMessageAlert(translate("password_recovery_email_error"))
                    }
                })
            }))
            self.presentViewController(alert, animated: true, completion: nil)

        })
    }
    
}












