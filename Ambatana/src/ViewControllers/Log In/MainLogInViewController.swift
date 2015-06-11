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
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberPasswordButton: UIButton!
    
    // Footer
    @IBOutlet weak var notRegisteredLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: MainLogInViewModel(), nibName: "MainLogInViewController")
    }
    
    required init(viewModel: MainLogInViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        
        // Navigation bar
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("closeButtonPressed"))
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let vc = MainSignUpViewController()
        navigationController?.setViewControllers([vc], animated: false)
    }
    
    // MARK: - Private methods
    
    private func pushLogInViewController() {
        let vc = LogInViewController()
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func pushRememberPasswordViewController() {
        
    }
}