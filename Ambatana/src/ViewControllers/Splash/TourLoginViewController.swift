//
//  TourLoginViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

final class TourLoginViewController: BaseViewController {
    
    let viewModel: TourLoginViewModel
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
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
    }
    
    
    // MARK: - IBAactions

    @IBAction func signUpPressed(sender: AnyObject) {
    }
    @IBAction func loginPressed(sender: AnyObject) {
    }
    @IBAction func skipPressed(sender: AnyObject) {
    }
}