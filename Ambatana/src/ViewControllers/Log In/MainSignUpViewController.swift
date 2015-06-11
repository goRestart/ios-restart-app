//
//  MainSignUpViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

class MainSignUpViewController: BaseViewController {
    
    // ViewModel
    var viewModel: MainSignUpViewModel!
    
    // UI
    // > Header
    @IBOutlet weak var claimLabel: UILabel!
    
    // > Main View
    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    // Footer
    @IBOutlet weak var registeredLabel: UILabel!
    @IBOutlet weak var logInLabel: UILabel!
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: MainSignUpViewModel(), nibName: "MainSignUpViewController")
    }
    
    required init(viewModel: MainSignUpViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("closeButtonPressed"))
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    // MARK: - Public methods
    
    // MARK: > Actions
    
    func closeButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func connectFBButtonPressed(sender: AnyObject) {
         pushSignUpViewController()
    }
    
    @IBAction func emailButtonPressed(sender: AnyObject) {
         pushSignUpViewController()
    }
    
    
    @IBAction func logInButtonPressed(sender: AnyObject) {
        let vc = MainLogInViewController()
        navigationController?.setViewControllers([vc], animated: false)
    }
    
    // MARK: - Private methods
    
    private func pushSignUpViewController() {
        let vc = SignUpViewController()
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        navigationController?.view.layer.addAnimation(transition, forKey: nil)
        navigationController?.pushViewController(vc, animated: false)
    }
}
