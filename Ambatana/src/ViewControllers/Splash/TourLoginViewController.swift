//
//  TourLoginViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import JBKenBurnsView
import LGCoreKit

final class TourLoginViewController: BaseViewController {
    
    let viewModel: TourLoginViewModel
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var kenBurnsView: JBKenBurnsView!
    
    var completion: (() -> ())?
    
    
    // MARK: - Lifecycle
    
    init(viewModel: TourLoginViewModel, completion: (() -> ())?) {
        self.viewModel = viewModel
        self.completion = completion
        super.init(viewModel: viewModel, nibName: "TourLoginViewController", statusBarStyle: .LightContent,
                   navBarBackgroundStyle: .Transparent)
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve

        let closeButton = UIBarButtonItem(image: UIImage(named: "ic_close"), style: .Plain, target: self,
            action: #selector(TourLoginViewController.closeButtonPressed(_:)))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAccessibilityIds()
    }

    override func viewDidFirstAppear(animated: Bool) {
        setupKenBurns()
    }
    
    
    // MARK: - UI
    
    func setupKenBurns() {
        let images: [UIImage] = [
            UIImage(named: "bg_1_new"),
            UIImage(named: "bg_2_new"),
            UIImage(named: "bg_3_new"),
            UIImage(named: "bg_4_new")
            ].flatMap{return $0}
        view.layoutIfNeeded()
        kenBurnsView.animateWithImages(images, transitionDuration: 10, initialDelay: 0, loop: true, isLandscape: true)
    }
    
    func setupUI() {
        signupButton.titleLabel?.font = UIFont.tourButtonFont
        signupButton.setTitle(LGLocalizedString.signUpSendButton, forState: .Normal)
        signupButton.setStyle(.Primary(fontSize: .Medium))
        signupButton.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        
        loginButton.backgroundColor = UIColor.clearColor()
        loginButton.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        loginButton.tintColor = UIColor.whiteColor()
        loginButton.titleLabel?.font = UIFont.tourButtonFont
        loginButton.setTitle(LGLocalizedString.logInSendButton, forState: .Normal)
        
        skipButton.backgroundColor = UIColor.clearColor()
        skipButton.tintColor = UIColor.whiteColor()
        skipButton.titleLabel?.font = UIFont.tourButtonFont
        skipButton.setTitle(LGLocalizedString.onboardingLoginSkip, forState: .Normal)
        
        messageLabel.text = LGLocalizedString.tourPage1Body
        
        kenBurnsView.clipsToBounds = true
    }

    func setupAccessibilityIds() {
        closeButton.accessibilityId = .TourLoginCloseButton
        signupButton.accessibilityId = .TourLoginSignUpButton
        loginButton.accessibilityId = .TourLoginLogInButton
        skipButton.accessibilityId = .TourLoginSkipButton
    }
    
    
    // MARK: - Navigation
    
    func openNextStep() {
        guard let step = viewModel.nextStep() else { return }
        switch step {
        case .Notifications:
            openNotificationsTour()
        case .Location:
            openLocationTour()
        case .None:
            close(true)
        }
    }
    
    func close(animated: Bool = false) {
        dismissViewControllerAnimated(animated, completion: completion)
    }
    
    func openNotificationsTour() {
        PushPermissionsManager.sharedInstance.showPrePermissionsViewFrom(self, type: .Onboarding) { [weak self] in
            self?.close()
        }
        
        UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.alpha = 0
        }, completion: nil)
    }
    
    func openLocationTour() {
        let vm = TourLocationViewModel(source: .Install)
        let vc = TourLocationViewController(viewModel: vm)
        vc.completion = { [weak self] in
            self?.close(false)
        }
        presentStep(vc)
    }
    
    func presentStep(vc: UIViewController) {
        UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.alpha = 0
        }, completion: nil)
        presentViewController(vc, animated: true, completion: nil)
    }
    
    
    // MARK: - IBActions
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.openNextStep()
    }

    @IBAction func signUpPressed(sender: AnyObject) {
        let vm = SignUpLogInViewModel(source: .Install, action: .Signup)
        let vc = SignUpLogInViewController(viewModel: vm)
        vc.afterLoginAction = { [weak self] in
            self?.openNextStep()
        }
        let nav = UINavigationController(rootViewController: vc)
        presentViewController(nav, animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        let vm = SignUpLogInViewModel(source: .Install, action: .Login)
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
