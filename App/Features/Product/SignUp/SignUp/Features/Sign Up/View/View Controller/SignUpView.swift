import UI
import SnapKit
import Domain
import RxSwift
import RxCocoa

private enum ViewLayout {
  static let scrollViewBottomSpace = CGFloat(80)
  static let inputHeight = CGFloat(48)
}

final class SignUpView: View {
  private let scrollView = UIScrollView()
  
  fileprivate let usernameTextField: InputTextField = {
    let textField = InputTextField()
    textField.input.autocapitalizationType = .none
    textField.input.textContentType = .username
    textField.input.returnKeyType = .next
    textField.title = Localize("signup.input.username.title", table: Table.signUp)
    textField.input.placeholder = Localize("signup.input.username.placeholder", table: Table.signUp)
    return textField
  }()
  
  fileprivate let emailTextField: InputTextField = {
    let textField = InputTextField()
    textField.input.autocapitalizationType = .none
    textField.input.keyboardType = .emailAddress
    textField.input.textContentType = .emailAddress
    textField.input.returnKeyType = .next
    textField.title = Localize("signup.input.email.title", table: Table.signUp)
    textField.input.placeholder = Localize("signup.input.email.placeholder", table: Table.signUp)
    return textField
  }()
  
  fileprivate let passwordTextField: InputTextField = {
    let textField = InputTextField()
    textField.input.isSecureTextEntry = true
    textField.input.textContentType = .password
    textField.input.returnKeyType = .join
    textField.title = Localize("signup.input.password.title", table: Table.signUp)
    textField.input.placeholder = Localize("signup.input.password.placeholder", table: Table.signUp)
    return textField
  }()

  fileprivate let signUpButton: FullWidthButton = {
    let button = FullWidthButton()
    let title = Localize("signup.button.signup.title", Table.signUp).uppercased()
    button.setTitle(title, for: .normal)
    return button
  }()
  
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.distribution = .equalSpacing
    stackView.axis = .vertical
    stackView.spacing = Margin.medium
    return stackView
  }()
  
  private let bag = DisposeBag()
  
  fileprivate func set(_ error: RegisterUserError?) {
    guard let error = error else { cleanErrors(); return }
    cleanErrors()
    
    switch error {
    case .invalidUsername:
      usernameTextField.error = Localize("signup.form.error.invalid_username", table: Table.signUp)
    case .invalidPassword:
      passwordTextField.error = Localize("signup.form.error.invalid_password", table: Table.signUp)
    case .invalidEmail:
      emailTextField.error = Localize("signup.form.error.invalid_email", table: Table.signUp)
    case .usernameIsAlreadyRegistered:
      usernameTextField.error = Localize("signup.form.error.username_is_already_registered", table: Table.signUp)
    case .emailIsAlreadyRegistered:
      emailTextField.error = Localize("signup.form.error.email_is_already_registered", table: Table.signUp)
    }
  }
  
  @discardableResult
  override func resignFirstResponder() -> Bool {
    usernameTextField.resignFirstResponder()
    emailTextField.resignFirstResponder()
    passwordTextField.resignFirstResponder()
    return super.resignFirstResponder()
  }
  
  private func cleanErrors() {
    usernameTextField.error = nil
    emailTextField.error = nil
    passwordTextField.error = nil
  }
  
  override func setupView() {
    stackView.addArrangedSubview(usernameTextField)
    stackView.addArrangedSubview(emailTextField)
    stackView.addArrangedSubview(passwordTextField)
    
    scrollView.addSubview(stackView)

    addSubview(scrollView)
    addSubview(signUpButton)
    
    usernameTextField.becomeFirstResponder()
  }
  
  override func setupConstraints() {
    scrollView.contentInset = UIEdgeInsets(top: Margin.huge, left: 0, bottom: 0, right: 0)
    
    signUpButton.snp.makeConstraints { make in
      make.left.equalTo(self).offset(Margin.medium)
      make.right.equalTo(self).offset(-Margin.medium)
      make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-Margin.medium)
    }
    
    Keyboard.subscribe(to: [.willShow, .willHide]).subscribe(onNext: { keyboard in
      self.scrollView.snp.remakeConstraints { make in
        if keyboard.event == .willShow {
          let bottomSpace = keyboard.endFrame.height + FullWidthButton.Layout.height + Margin.medium
          make.edges.equalTo(self)
            .inset(UIEdgeInsets.init(top: 0, left: 0, bottom: bottomSpace, right: 0))
        } else {
          make.edges.equalTo(self)
            .inset(UIEdgeInsets.init(top: 0, left: 0, bottom: ViewLayout.scrollViewBottomSpace, right: 0))
        }
      }

      self.signUpButton.snp.remakeConstraints { make in
        if keyboard.event == .willHide {
          make.left.equalTo(self).offset(Margin.medium)
          make.right.equalTo(self).offset(-Margin.medium)
          make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-Margin.medium)
        } else {
          make.left.equalTo(self)
          make.right.equalTo(self)
          make.bottom.equalTo(-keyboard.endFrame.height)
        }
        make.height.equalTo(FullWidthButton.Layout.height)
      }

      UIView.animate(withDuration: keyboard.animationDuration,
                     delay: 0, options: .curveEaseIn, animations: { [weak self] in
        self?.signUpButton.radiusDisabled = keyboard.event == .willHide ? false : true
        self?.layoutIfNeeded()
      })
      
    }).disposed(by: bag)
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalTo(self)
        .inset(UIEdgeInsets.init(top: 0, left: 0, bottom: ViewLayout.scrollViewBottomSpace, right: 0))
    }
    
    stackView.snp.makeConstraints { make in
      make.edges.equalTo(scrollView)
        .inset(UIEdgeInsets.init(top: 0, left: Margin.medium, bottom: 0, right: Margin.medium))
    }
    
    [usernameTextField, emailTextField, passwordTextField].forEach { input in
      input.snp.makeConstraints { make in
        make.left.equalTo(self).offset(Margin.medium)
        make.right.equalTo(self).offset(-Margin.medium)
      }
    }
  }
}

// MARK: - Actions

extension SignUpView {
  func onUsernameEndEditing() {
    emailTextField.becomeFirstResponder()
  }
  
  func onEmailEndEditing() {
    passwordTextField.becomeFirstResponder()
  }
}

// MARK: - View bindings

extension Reactive where Base: SignUpView {
  var error: Binder<RegisterUserError?> {
    return Binder(base) { base, error in
      base.set(error)
    }
  }
  
  var username: ControlProperty<String> {
    return base.usernameTextField.input.rx.value.orEmpty
  }
  
  var email: ControlProperty<String> {
    return base.emailTextField.input.rx.value.orEmpty
  }
  
  var password: ControlProperty<String> {
    return base.passwordTextField.input.rx.value.orEmpty
  }
  
  var usernameEndEditing: ControlEvent<Void> {
    return base.passwordTextField.input.rx.controlEvent(.editingDidEndOnExit)
  }
  
  var emailEndEditing: ControlEvent<Void> {
    return base.passwordTextField.input.rx.controlEvent(.editingDidEndOnExit)
  }
  
  var signUpButtonEnabled: Binder<Bool> {
    return Binder(base) { view, enabled in
      view.signUpButton.isEnabled = enabled
    }
  }
  
  var signUpButtonIsLoading: Binder<SignUpState> {
    return Binder(base) { base, state in
      base.signUpButton.isLoading = state == .loading
    }
  }

  var signUpButtonWasTapped: Observable<Void> {
    return base.signUpButton.rx.buttonWasTapped
  }
  
  var userInteractionEnabled: Binder<Bool> {
    return Binder(base) { view, enabled in
      view.usernameTextField.isUserInteractionEnabled = enabled
      view.emailTextField.isUserInteractionEnabled = enabled
      view.passwordTextField.isUserInteractionEnabled = enabled
      view.signUpButton.isUserInteractionEnabled = enabled
    }
  }
  
  var viewWasTapped: ControlEvent<UITapGestureRecognizer> {
    let tapGestureRecognizer = UITapGestureRecognizer()
    base.addGestureRecognizer(tapGestureRecognizer)
    return tapGestureRecognizer.rx.event
  }
}
