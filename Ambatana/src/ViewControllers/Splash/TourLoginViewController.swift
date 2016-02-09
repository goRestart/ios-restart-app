//
//  TourLoginViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import CoreLocation
import JBKenBurnsView

final class TourLoginViewController: BaseViewController {
    
    let viewModel: TourLoginViewModel
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var kenBurnsView: JBKenBurnsView!
    
    // MARK: - Lifecycle
    
    init(viewModel: TourLoginViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "TourLoginViewController")
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
        setLetGoNavigationBarStyle()
        
        let closeButton = UIBarButtonItem(image: UIImage(named: "ic_close"), style: .Plain, target: self,
            action: Selector("closeButtonPressed"))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        setNeedsStatusBarAppearanceUpdate()
        
        let images: [UIImage] = [
            UIImage(named: "bg_1_new"),
            UIImage(named: "bg_2_new"),
            UIImage(named: "bg_3_new"),
            UIImage(named: "bg_4_new")
            ].flatMap{return $0}

        kenBurnsView.animateWithImages(images, transitionDuration: 10, initialDelay: 0, loop: true, isLandscape: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    func setupUI() {
        signupButton.backgroundColor = StyleHelper.primaryColor
        signupButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
        signupButton.tintColor = UIColor.whiteColor()
        signupButton.titleLabel?.font = StyleHelper.tourButtonFont
        signupButton.setTitle(LGLocalizedString.signUpSendButton, forState: .Normal)
        
        loginButton.backgroundColor = UIColor.clearColor()
        loginButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        loginButton.tintColor = UIColor.whiteColor()
        loginButton.titleLabel?.font = StyleHelper.tourButtonFont
        loginButton.setTitle(LGLocalizedString.logInSendButton, forState: .Normal)
        
        skipButton.backgroundColor = UIColor.clearColor()
        skipButton.tintColor = UIColor.whiteColor()
        skipButton.titleLabel?.font = StyleHelper.tourButtonFont
        skipButton.setTitle(LGLocalizedString.tourPageSkipButton, forState: .Normal)
        
        messageLabel.text = LGLocalizedString.tourPage1Body
        
        
        kenBurnsView.clipsToBounds = true
    }
    
    
    // MARK: - Navigation
    
    func openNextStep() {
        if !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
            openNotificationsTour()
        } else if CLLocationManager.authorizationStatus() == .NotDetermined  {
            openLocationTour()
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func openNotificationsTour() {
        let vm = TourNotificationsViewModel(title: "", subtitle: "", pushText: "")
        let vc = TourNotificationsViewController(viewModel: vm)
        vc.completion = { [weak self] in
            self?.dismissViewControllerAnimated(false, completion: nil)
        }
        presentStep(vc)
    }
    
    func openLocationTour() {
        let vc = TourLocationViewController()
        vc.completion = { [weak self] in
            self?.dismissViewControllerAnimated(false, completion: nil)
        }
        presentStep(vc)
    }
    
    func presentStep(vc: UIViewController) {
        UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.alpha = 0
        }, completion: nil)
        presentViewController(vc, animated: true, completion: nil)
    }
    
    
    // MARK: - IBAactions
    
    func closeButtonPressed() {
        openNotificationsTour()
    }

    @IBAction func signUpPressed(sender: AnyObject) {
        let vm = SignUpLogInViewModel(source: .Onboarding, action: .Signup)
        let vc = SignUpLogInViewController(viewModel: vm)
        vc.afterLoginAction = { [weak self] in
            self?.openNextStep()
        }
        let nav = UINavigationController(rootViewController: vc)
        presentViewController(nav, animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        let vm = SignUpLogInViewModel(source: .Onboarding, action: .Login)
        let vc = SignUpLogInViewController(viewModel: vm)
        vc.afterLoginAction = { [weak self] in
            self?.openNextStep()
        }
        let nav = UINavigationController(rootViewController: vc)
        presentViewController(nav, animated: true, completion: nil)
    }
    
    @IBAction func skipPressed(sender: AnyObject) {
        openNextStep()
    }
}
