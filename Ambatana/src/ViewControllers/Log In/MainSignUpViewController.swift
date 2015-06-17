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
    
    // ViewModel
    var viewModel: MainSignUpViewModel!
    
    // UI
    // > Header
    @IBOutlet weak var claimLabel: UILabel!
    
    // > Main View
    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    // Footer
    @IBOutlet weak var registeredLabel: UILabel!
    @IBOutlet weak var logInLabel: UILabel!
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: MainSignUpViewModel(), nibName: "MainSignUpViewController")
    }
    
    required init(viewModel: MainSignUpViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel.delegate = self
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dividerView.addBottomBorderWithWidth(1, color: StyleHelper.lineColor)
        emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor)
        emailButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor)
    }
    
    // MARK: - Actions
    
    func closeButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func connectFBButtonPressed(sender: AnyObject) {
         viewModel.logInWithFacebook()
    }
    
    @IBAction func emailButtonPressed(sender: AnyObject) {
        let vc = SignUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logInButtonPressed(sender: AnyObject) {
        let vc = LogInViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - MainSignUpViewModelDelegate
    
    func viewModelDidStartLoggingWithFB(viewModel: MainSignUpViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: MainSignUpViewModel, didFinishLoggingWithFBWithResult result: Result<User, UserLogInFBError>) {
        
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            break
        case .Failure(let error):
            
            var message: String?
            switch (error.value) {
            case .Cancelled:
                break
            case .Network:
                message = NSLocalizedString("error_connection_failed", comment: "")
            case .Internal:
                message = NSLocalizedString("main_sign_up_fb_connect_error_generic_error", comment: "")
            }
            completion = {
                if let actualMessage = message {
                    self.showAutoFadingOutMessageAlert(actualMessage)
                }
            }
        }
        dismissLoadingMessageAlert(completion: completion)
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setupUI() {
        
        // Navigation bar
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("closeButtonPressed"))
        self.navigationItem.leftBarButtonItem = closeButton;
        
        // Appearance
        connectFBButton.setBackgroundImage(connectFBButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        connectFBButton.layer.cornerRadius = 4
        
        // i18n
        claimLabel.text = NSLocalizedString("main_sign_up_claim", comment: "")
        connectFBButton.setTitle(NSLocalizedString("main_sign_up_facebook_connect_button", comment: ""), forState: .Normal)
        orLabel.text = NSLocalizedString("main_sign_up_or_label", comment: "")
        emailTextField.placeholder = NSLocalizedString("main_sign_up_email_field_placeholder", comment: "")
        registeredLabel.text = NSLocalizedString("main_sign_up_already_registered_label", comment: "")
        logInLabel.text = NSLocalizedString("main_sign_up_log_in_label", comment: "")
    }
}
