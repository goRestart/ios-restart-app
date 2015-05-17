//
//  ViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Parse
import UIKit

@objc protocol LoginAndSigninDelegate {
    optional func loginDelegateSignIn()
    optional func loginDelegateSignUp()
    optional func loginDelegateConnectWithFacebook()
    optional func loginDelegateRecoverPassword(email: String)
}

class LoginViewController: UIViewController, LoginAndSigninDelegate, UIAlertViewDelegate {
    // outlets && buttons
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var letgoLoginLabel: UILabel!
    @IBOutlet weak var orUseEmailLabel: UILabel!
    
    // vars & data
    var recoveryEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // internationalization
        letgoLoginLabel.text = translate("fun_unique_way")
        facebookLoginButton.setTitle(translate("connect_with_facebook"), forState: .Normal)
        signupButton.setTitle(translate("signup"), forState: .Normal)
        loginButton.setTitle(translate("login"), forState: .Normal)
        orUseEmailLabel.text = translate("or_use_your_email").uppercaseString
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // check current login status
        if (PFUser.currentUser() != nil) { // && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser())) {
            ConfigurationManager.sharedInstance.loadDataFromCurrentUser()
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(0.01 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.openTabBarController()
            }
        } else {
            self.view.hidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.hidden = true
    }
    
    // MARK: - reacting to login notifications
    
    func oauthSessionExpired(notification: NSNotification) {
        if iOSVersionAtLeast("8.0") {
            let alert = UIAlertController(title: translate("session_expired"), message: translate("your_session_has_expired"), preferredStyle:.Alert)
            alert.addAction(UIAlertAction(title: translate("ok"), style:.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertView(title: translate("session_expired"), message: translate("your_session_has_expired"), delegate: nil, cancelButtonTitle: translate("ok"))
            alert.show()
        }
    }
    
    func authenticationError(notification: NSNotification) {
        if iOSVersionAtLeast("8.0") {
            let alert = UIAlertController(title: translate("authentication_error"), message: translate("unable_access_system"), preferredStyle:.Alert)
            alert.addAction(UIAlertAction(title: translate("ok"), style:.Default, handler:nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertView(title: translate("authentication_error"), message: translate("unable_access_system"), delegate: nil, cancelButtonTitle: translate("ok"))
            alert.show()
        }
    }
    
    // MARK: - Button actions
    
    @IBAction func connectWithFacebook(sender: UIButton) {
        let permissionsArray = ["user_about_me", "user_location", "email", "public_profile"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissionsArray, block: { (user, error) -> Void in
            if user != nil { // login succeed
                if user!.isNew { // if we have just created the new user we need to set the Facebook
                    // load facebook data into profile.
                    //println("User created for the first time by Facebook.")
                    ConfigurationManager.sharedInstance.loadInitialFacebookProfileData()
                } else { // load configuration from previous user
                    ConfigurationManager.sharedInstance.loadDataFromCurrentUser()
                }
                
                // If we already have a location, then save it into my user
                if let lastKnownLocation = LocationManager.sharedInstance.lastKnownLocation {
                    MyUserManager.sharedInstance.saveUserCoordinates(lastKnownLocation.coordinate)
                }
                
                // track user login/signing with facebook
                TrackingHelper.trackEvent(.LoginFB, parameters: nil)
                
                // go to root
                self.openTabBarController()
            } else { // error login
                //println("Error: \(error)")
                if iOSVersionAtLeast("8.0") {
                    let alert = UIAlertController(title: translate("unable_login"), message: translate("login_canceled"), preferredStyle:.Alert)
                    alert.addAction(UIAlertAction(title: translate("ok"), style:.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertView(title: translate("unable_login"), message: translate("login_canceled"), delegate: nil, cancelButtonTitle: translate("ok"))
                    alert.show()
                }
            }
        })
        
        
    }
    
    @IBAction func signUp(sender: UIButton) {
        // DO NOTHING, SEGUE IS PERFORMED IN IB.
    }
    
    @IBAction func login(sender: UIButton) {
        // DO NOTHING, SEGUE IS PERFORMED IN IB.
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
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            self.performSegueWithIdentifier("LoginByEmail", sender: nil)
        })
    }
    
    func loginDelegateSignUp() {
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            self.performSegueWithIdentifier("SignUp", sender: nil)
        })
    }
    
    func loginDelegateConnectWithFacebook() {
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            self.connectWithFacebook(self.facebookLoginButton)
        })
    }
    
    func loginDelegateRecoverPassword(email: String) {
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            if iOSVersionAtLeast("8.0") {
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
            } else {
                self.recoveryEmail = email
                let alert = UIAlertView(title: translate("password_recovery"), message: translate("send_recovery_email_question"), delegate: self, cancelButtonTitle: translate("cancel"), otherButtonTitles: translate("ok"))
                alert.show()
            }
            

        })
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 1 { // user clicked "ok".
            PFUser.requestPasswordResetForEmailInBackground(recoveryEmail ?? "", block: { (success, error) -> Void in
                if success {
                    self.showAutoFadingOutMessageAlert(translate("password_recovery_email_sent"))
                } else {
                    self.showAutoFadingOutMessageAlert(translate("password_recovery_email_error"))
                }
            })
        }
    }

    func openTabBarController() {
        let tabCtl = TabBarController()
        self.presentViewController(tabCtl, animated: false, completion: nil)
    }
}












