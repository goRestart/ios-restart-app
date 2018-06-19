import LGCoreKit
import Result
import UIKit
import LGComponents

class ChangePasswordViewController: BaseViewController, UITextFieldDelegate, ChangePasswordViewModelDelegate {

    enum TextFieldTag: Int {
        case password = 1000, confirmPassword
    }

    let passwordTextfield: LGTextField = {
        let textfield = LGTextField()
        textfield.tag = TextFieldTag.password.rawValue
        textfield.placeholder = R.Strings.changePasswordNewPasswordFieldHint
        textfield.backgroundColor = .white
        textfield.isSecureTextEntry = true
        return textfield
    }()

    let confirmPasswordTextfield: LGTextField = {
        let textfield = LGTextField()
        textfield.tag = TextFieldTag.confirmPassword.rawValue
        textfield.placeholder = R.Strings.changePasswordConfirmPasswordFieldHint
        textfield.backgroundColor = .white
        textfield.isSecureTextEntry = true
        return textfield
    }()

    let sendButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.setTitle(R.Strings.changePasswordTitle, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    let viewModel: ChangePasswordViewModel
    var lines : [CALayer] = []

    init(viewModel: ChangePasswordViewModel) {
        self.viewModel = viewModel
        self.lines = []
        super.init(viewModel:viewModel, nibName: nil)
        self.viewModel.delegate = self
    }
    
    convenience init() {
        let viewModel = ChangePasswordViewModel()
        self.init(viewModel: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBarBackButton()
        setupUI()
        setupAccessibilityIds()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavBarBackgroundStyle(.default)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextfield.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(passwordTextfield.addTopBorderWithWidth(1, color: UIColor.lineGray))
        lines.append(confirmPasswordTextfield.addTopBorderWithWidth(1, color: UIColor.lineGray))
        lines.append(confirmPasswordTextfield.addBottomBorderWithWidth(1, color: UIColor.lineGray))
    }
   
    @objc func sendChangePasswordButtonPressed(_ sender: AnyObject) {
        viewModel.changePassword()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    // MARK: - TextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let textFieldText = textField.text {
            let text = (textFieldText as NSString).replacingCharacters(in: range, with: string)
            if let tag = TextFieldTag(rawValue: textField.tag) {
                switch (tag) {
                case .password:
                    viewModel.password = text
                case .confirmPassword:
                    viewModel.confirmPassword = text
                }
            }
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            switch (tag) {
            case .password:
                viewModel.password = ""
            case .confirmPassword:
                viewModel.confirmPassword = ""
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.passwordTextfield {
            self.confirmPasswordTextfield.becomeFirstResponder()
        } else if textField == self.confirmPasswordTextfield {
            viewModel.changePassword()
        }
        return false
    }
    
    // MARK : - ChangePasswordViewModelDelegate Methods
    
    func viewModelDidStartSendingPassword(_ viewModel: ChangePasswordViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(_ viewModel: ChangePasswordViewModel, didFailValidationWithError error: ChangePasswordError) {
        let message: String
        switch (error) {
        case .invalidPassword:
            message = R.Strings.changePasswordSendErrorInvalidPasswordWithMax(SharedConstants.passwordMinLength,
                SharedConstants.passwordMaxLength)
        case .passwordMismatch:
            message = R.Strings.changePasswordSendErrorPasswordsMismatch
        case .resetPasswordLinkExpired:
            message = R.Strings.changePasswordSendErrorLinkExpired
        case .network, .internalError:
            message = R.Strings.changePasswordSendErrorGeneric
        }
        self.showAutoFadingOutMessageAlert(message: message)
    }
    
    func viewModel(_ viewModel: ChangePasswordViewModel, didFinishSendingPasswordWithResult
        result: Result<MyUser, ChangePasswordError>) {
            var completion: (() -> Void)? = nil
            
            switch (result) {
            case .success:
                completion = {
                    self.passwordTextfield.text = ""
                    self.confirmPasswordTextfield.text = ""
                    
                    self.showAutoFadingOutMessageAlert(message: R.Strings.changePasswordSendOk) { [weak self] in
                        self?.viewModel.passwordChangedCorrectly()
                    }
                }
                break
            case .failure(let error):
                let message: String
                switch (error) {
                case .invalidPassword:
                    message = R.Strings.changePasswordSendErrorInvalidPasswordWithMax(
                        SharedConstants.passwordMinLength, SharedConstants.passwordMaxLength)
                case .passwordMismatch:
                    message = R.Strings.changePasswordSendErrorPasswordsMismatch
                case .resetPasswordLinkExpired:
                    message = R.Strings.changePasswordSendErrorLinkExpired
                case .network, .internalError:
                    message = R.Strings.changePasswordSendErrorGeneric
                }
                completion = {
                    self.showAutoFadingOutMessageAlert(message: message)
                }
            }
            dismissLoadingMessageAlert(completion)
    }
    
    func viewModel(_ viewModel: ChangePasswordViewModel, updateSendButtonEnabledState enabled: Bool) {
        sendButton.isEnabled = enabled
    }
    
    
    // MARK: Private methods
    
    private func setupUI() {
        view.addSubviewsForAutoLayout([passwordTextfield, confirmPasswordTextfield, sendButton])
        if isRootViewController() {
            let closeButton = UIBarButtonItem(image: R.Asset.IconsButtons.navbarClose.image, style: .plain, target: self,
                action: #selector(popBackViewController))
            navigationItem.leftBarButtonItem = closeButton
        }
        
        passwordTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        setNavBarTitle(R.Strings.changePasswordTitle)
        confirmPasswordTextfield.placeholder = R.Strings.changePasswordConfirmPasswordFieldHint
        sendButton.addTarget(self, action: #selector(sendChangePasswordButtonPressed(_:)), for: .touchUpInside)
        setupConstraints()
    }

    private func setupConstraints() {
        let constraints: [NSLayoutConstraint] = [
            passwordTextfield.topAnchor.constraint(equalTo: safeTopAnchor, constant: 90),
            passwordTextfield.leftAnchor.constraint(equalTo: view.leftAnchor),
            passwordTextfield.rightAnchor.constraint(equalTo: view.rightAnchor),
            passwordTextfield.heightAnchor.constraint(equalToConstant: 44),
            confirmPasswordTextfield.topAnchor.constraint(equalTo: passwordTextfield.bottomAnchor),
            confirmPasswordTextfield.leftAnchor.constraint(equalTo: view.leftAnchor),
            confirmPasswordTextfield.rightAnchor.constraint(equalTo: view.rightAnchor),
            confirmPasswordTextfield.heightAnchor.constraint(equalToConstant: 44),
            sendButton.topAnchor.constraint(equalTo: confirmPasswordTextfield.bottomAnchor, constant: Metrics.margin),
            sendButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Metrics.margin),
            sendButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Metrics.margin),
            sendButton.heightAnchor.constraint(equalToConstant: 50)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupAccessibilityIds() {
        passwordTextfield.set(accessibilityId: .changePasswordPwdTextfield)
        confirmPasswordTextfield.set(accessibilityId: .changePasswordPwdConfirmTextfield)
        sendButton.set(accessibilityId: .changePasswordSendButton)
    }
}
