import LGCoreKit
import Foundation
import Result
import RxSwift
import LGComponents

extension ChangeEmailViewController: ChangeEmailViewModelDelegate {}

class ChangeEmailViewController: BaseViewController, UITextFieldDelegate {
    
    private let customView: ChangeEmailView
    private let viewModel: ChangeEmailViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    init(with viewModel: ChangeEmailViewModel) {
        self.viewModel = viewModel
        self.customView = ChangeEmailView()
        
        super.init(viewModel: viewModel, nibName: nil)
        
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupAccessibilityIds()
        setupRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        customView.emailTextField.becomeFirstResponder()
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        customView.addToViewController(self, inView: view)
        setNavBarTitle(R.Strings.changeEmailTitle)
        customView.emailTitleLabel.text = R.Strings.changeEmailCurrentEmailLabel
        customView.emailLabel.text = viewModel.currentEmail
        customView.emailTextField.placeholder = R.Strings.changeEmailFieldHint
        customView.emailTextField.delegate = self
        customView.saveButton.setTitle(R.Strings.changeUsernameSaveButton, for: .normal)
        customView.saveButton.isEnabled = false
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        customView.emailLabel.set(accessibilityId: .changeEmailCurrentEmailLabel)
        customView.emailTextField.set(accessibilityId: .changeEmailTextField)
        customView.saveButton.set(accessibilityId: .changeEmailSendButton)
    }
    
    private func setupRx() {
        customView.saveButton.rx.tap.subscribeNext { [weak self] in
            self?.viewModel.updateEmail()
        }.disposed(by: disposeBag)
        customView.emailTextField.rx.text.bind(to: viewModel.newEmail).disposed(by: disposeBag)
        viewModel.shouldAllowToContinue.distinctUntilChanged().bind(to: customView.saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.updateEmail()
        return true
    }
}
