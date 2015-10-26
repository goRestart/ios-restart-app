//
//  MainSignUpViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

class MainSignUpViewController: BaseViewController, MainSignUpViewModelDelegate {

    // Data
    var afterLoginAction: (() -> Void)?
    
    // > ViewModel
    var viewModel: MainSignUpViewModel!
    
    // > Delegate
    
    // UI
    
    // > Nav Bar
    var navBarBgImage: UIImage!
    var navBarShadowImage: UIImage!

    // > Header
    @IBOutlet weak var claimLabel: UILabel!
    
    // > Main View
    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var signUpButton: UIButton!
    
    // Footer
    @IBOutlet weak var registeredLabel: UILabel!
    @IBOutlet weak var logInLabel: UILabel!
    @IBOutlet weak var contactUsButton: UIButton!
    
    // > Helper
    var lines: [CALayer]
    
    // MARK: - Lifecycle
    
    init(source: EventParameterLoginSourceValue) {
        self.viewModel = MainSignUpViewModel(source: source)
        self.lines = []
        super.init(viewModel: viewModel, nibName: "MainSignUpViewController")
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        navBarBgImage = navigationController?.navigationBar.backgroundImageForBarMetrics(.Default)
        navBarShadowImage = navigationController?.navigationBar.shadowImage
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(navBarBgImage, forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = navBarShadowImage
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(dividerView.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
    }
    
    // MARK: - Actions
    
    func closeButtonPressed() {
        viewModel.abandon()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func connectFBButtonPressed(sender: AnyObject) {
         viewModel.logInWithFacebook()
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        let vc = SignUpViewController(source: viewModel.loginSource)
        vc.afterLoginAction = afterLoginAction
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logInButtonPressed(sender: AnyObject) {
        let vc = LogInViewController(source: viewModel.loginSource)
        vc.afterLoginAction = afterLoginAction
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func contactUsButtonPressed() {
        let vc = HelpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - MainSignUpViewModelDelegate
    
    func viewModelDidStartLoggingWithFB(viewModel: MainSignUpViewModel) {
        showCustomLoadingMessageAlert()
    }
    
    func viewModel(viewModel: MainSignUpViewModel, didFinishLoggingWithFBWithResult result: UserLogInFBResult) {
        
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.dismissViewControllerAnimated(true, completion: self.afterLoginAction)
            }
            break
        case .Failure(let error):
            
            var message: String?
            switch (error) {
            case .Cancelled:
                break
            case .EmailTaken:
                message = LGLocalizedString.mainSignUpFbConnectErrorEmailTaken
            case .Internal, .Network, .Forbidden, .InvalidPassword, .PasswordMismatch, .UsernameTaken:
                message = LGLocalizedString.mainSignUpFbConnectErrorGeneric
            }
            completion = {
                if let actualMessage = message {
                    self.showAutoFadingOutMessageAlert(actualMessage, time: 3)
                }
            }
        }
        dismissCustomLoadingMessageAlert(completion)
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setupUI() {
        
        // Navigation bar
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .Plain, target: self, action: Selector("closeButtonPressed"))
        navigationItem.leftBarButtonItem = closeButton

        // Appearance
        connectFBButton.setBackgroundImage(connectFBButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        connectFBButton.layer.cornerRadius = 4
        signUpButton.setBackgroundImage(signUpButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        signUpButton.layer.cornerRadius = 4
        
        // i18n
        claimLabel.text = LGLocalizedString.mainSignUpClaimLabel
        connectFBButton.setTitle(LGLocalizedString.mainSignUpFacebookConnectButton, forState: .Normal)
        orLabel.text = LGLocalizedString.mainSignUpOrLabel
        signUpButton.setTitle(LGLocalizedString.mainSignUpSignUpButton, forState: .Normal)
        registeredLabel.text = LGLocalizedString.mainSignUpAlreadyRegisteredLabel
        logInLabel.text = LGLocalizedString.mainSignUpLogInLabel
        contactUsButton.setTitle(LGLocalizedString.mainSignUpContactUsButton, forState: .Normal)
    }
}
