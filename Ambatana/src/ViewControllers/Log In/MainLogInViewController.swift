//
//  MainLogInViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

class MainLogInViewController: BaseViewController {

    // ViewModel
    var viewModel: MainLogInViewModel!
    
    // UI
    // > Header
    @IBOutlet weak var claimLabel: UILabel!
    
    // > Main View
    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var orLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var rememberPasswordButton: UIButton!
    
    // Footer
    @IBOutlet weak var notRegisteredLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: MainLogInViewModel(), nibName: "MainLogInViewController")
    }
    
    required init(viewModel: MainLogInViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
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
        passwordButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor)
    }
    
    // MARK: - Public methods
    
    // MARK: > Actions
    
    @IBAction func connectFBButtonPressed(sender: AnyObject) {
    
    }
    
    
    @IBAction func emailButtonPressed(sender: AnyObject) {
        pushLogInViewController()
    }
    
    
    @IBAction func passwordButtonPressed(sender: AnyObject) {
        pushLogInViewController()
    }
    
    @IBAction func rememberPasswordButtonPressed(sender: AnyObject) {
        pushRememberPasswordViewController()
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        navigationController?.view.layer.addAnimation(transition, forKey: nil)
        
        let vc = MainSignUpViewController()
        navigationController?.setViewControllers([vc], animated: false)
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        // Navigation bar
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("closeButtonPressed"))
        self.navigationItem.leftBarButtonItem = closeButton
        
        // Appearance
        connectFBButton.setBackgroundImage(connectFBButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        connectFBButton.layer.cornerRadius = 4
        
        // i18n
        claimLabel.text = NSLocalizedString("main_log_in_claim", comment: "")
        connectFBButton.setTitle(NSLocalizedString("main_log_in_facebook_connect_button", comment: ""), forState: .Normal)
        orLabel.text = NSLocalizedString("main_log_in_or_label", comment: "")
        emailTextField.placeholder = NSLocalizedString("main_log_in_email_field_placeholder", comment: "")
        passwordTextField.placeholder = NSLocalizedString("main_log_in_password_field_placeholder", comment: "")
        rememberPasswordButton.setTitle(NSLocalizedString("main_log_in_reset_password_button", comment: ""), forState: .Normal)
        notRegisteredLabel.text = NSLocalizedString("main_log_in_not_registered_label", comment: "")
        signUpLabel.text = NSLocalizedString("main_log_in_sign_up_label", comment: "")
    }
    
    // MARK: > Navigation
    
    private func pushLogInViewController() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        navigationController?.view.layer.addAnimation(transition, forKey: nil)
        
        let vc = LogInViewController()
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func pushRememberPasswordViewController() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        navigationController?.view.layer.addAnimation(transition, forKey: nil)
        
        let vc = RememberPasswordViewController()
        navigationController?.pushViewController(vc, animated: false)
    }
}