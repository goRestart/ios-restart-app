import LGCoreKit
import Result
import UIKit
import LGComponents

private enum Layout {
    enum usernameTextField {
        static let height = CGFloat(44)
    }
    
    enum passwordTextField {
        static let leading = CGFloat(15)
        static let trailing = CGFloat(15)
        static let bottom = CGFloat(15)
        static let height = CGFloat(44)
    }
}
final class ChangeUsernameViewController: BaseViewController, UITextFieldDelegate, ChangeUsernameViewModelDelegate {
 
    private let usernameTextField: LGTextField = {
        let textField = LGTextField()
        textField.backgroundColor = .white
        textField.placeholder = R.Strings.changeUsernameFieldHint
        return textField
    }()
    
    private let saveButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.setTitle(R.Strings.changeUsernameSaveButton, for: .normal)
        button.isEnabled = false
        return button
    }()
 
    let viewModel: ChangeUsernameViewModel
    
    var lines: [CALayer]
    
    init(vm: ChangeUsernameViewModel) {
        self.viewModel = vm
        self.lines = []
        super.init(viewModel: viewModel, nibName: nil)
        self.viewModel.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupAccessibilityIds()
        usernameTextField.text = viewModel.username
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameTextField.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(usernameTextField.addTopBorderWithWidth(1, color: UIColor.lineGray))
        lines.append(usernameTextField.addBottomBorderWithWidth(1, color: UIColor.lineGray))
        
    }
 
    @objc private func saveBarButtonPressed() {
        viewModel.saveUsername()
    }
    
    // MARK: - TextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.containsEmoji else { return false }
        guard let text = textField.text else { return false }
        let newLength = text.count + string.count - range.length
        let removing = text.count > newLength
        if !removing && newLength > SharedConstants.maxUserNameLength { return false }

        let updatedText =  (text as NSString).replacingCharacters(in: range, with: string)
        viewModel.username = updatedText
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.username = ""
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let textFieldText = textField.text {
            if viewModel.isValidUsername(textFieldText) {
                viewModel.saveUsername()
                return true
            }
            else {
                self.showAutoFadingOutMessageAlert(message: 
                    R.Strings.changeUsernameErrorInvalidUsername(SharedConstants.fullNameMinLength), time: 3.5)
                return false
            }
        } else {
            return false
        }
    }
    
    // MARK : - ChangeUsernameViewModelDelegate Methods
    
    func viewModelDidStartSendingUser(_ viewModel: ChangeUsernameViewModel) {
        showLoadingMessageAlert(R.Strings.changeUsernameLoading)
    }
    
    func viewModel(_ viewModel: ChangeUsernameViewModel, didFailValidationWithError error: ChangeUsernameError) {
        let message: String
        switch (error) {
        case .network, .internalError, .notFound, .unauthorized:
            message = R.Strings.commonErrorConnectionFailed
        case .invalidUsername:
            message = R.Strings.changeUsernameErrorInvalidUsername(SharedConstants.fullNameMinLength)
        case .usernameTaken:
            message = R.Strings.changeUsernameErrorInvalidUsernameLetgo(viewModel.username)
        }
        
        self.showAutoFadingOutMessageAlert(message: message)
    }
    
    func viewModel(_ viewModel: ChangeUsernameViewModel, didFinishSendingUserWithResult
        result: Result<MyUser, ChangeUsernameError>) {
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .success:
            completion = {
                self.showAutoFadingOutMessageAlert(message: R.Strings.changeUsernameSendOk) { [weak self] in
                    self?.viewModel.userNameSaved()
                }
            }
            break
        case .failure(let error):
            let message: String
            switch (error) {
            case .network, .internalError, .notFound, .unauthorized:
                message = R.Strings.commonErrorConnectionFailed
            case .invalidUsername:
                message = R.Strings.changeUsernameErrorInvalidUsername(SharedConstants.fullNameMinLength)
            case .usernameTaken:
                message = R.Strings.changeUsernameErrorInvalidUsernameLetgo(viewModel.username)
            }
            completion = { [weak self] in
                self?.showAutoFadingOutMessageAlert(message: message)
            }
        }
        
        dismissLoadingMessageAlert(completion)
    }
    
    func viewModel(_ viewModel: ChangeUsernameViewModel, updateSaveButtonEnabledState enabled: Bool) {
        saveButton.isEnabled = enabled
    }

    
    func setupUI() {
        view.addSubviewsForAutoLayout([
            usernameTextField, saveButton
        ])
        
        view.backgroundColor = .groupTableViewBackground
        
        usernameTextField.delegate = self
      
        setNavBarTitle(R.Strings.changeUsernameTitle)
        
        saveButton.addTarget(self, action: #selector(ChangeUsernameViewController.saveBarButtonPressed), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        let userNameConstraints = [
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            usernameTextField.topAnchor.constraint(equalTo: safeTopAnchor),
            usernameTextField.heightAnchor.constraint(equalToConstant: Layout.usernameTextField.height)
        ]
        userNameConstraints.activate()

        let buttonConstraints = [
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.passwordTextField.leading),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.passwordTextField.trailing),
            saveButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: Layout.passwordTextField.bottom),
            saveButton.heightAnchor.constraint(equalToConstant: Layout.passwordTextField.height)
        ]
        buttonConstraints.activate()
    }

    private func setupAccessibilityIds() {
        usernameTextField.set(accessibilityId: .changeUsernameNameField)
        saveButton.set(accessibilityId: .changeUsernameSendButton)
    }
}
