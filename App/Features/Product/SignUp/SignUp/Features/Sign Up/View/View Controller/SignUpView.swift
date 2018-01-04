import UI
import SnapKit
import Domain

private struct ViewLayout {
  static let signInButtonHeight = CGFloat(56)
  static let scrollViewBottomSpace = CGFloat(80)
  static let inputHeight = CGFloat(48)
}

final class SignUpView: View {
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    return scrollView
  }()

  let usernameTextField: InputTextField = {
    let textField = InputTextField()
    textField.input.autocapitalizationType = .none
    textField.input.textContentType = .username
    textField.input.returnKeyType = .next
    textField.title = Localize("signup.input.username.title", table: Table.signUp)
    textField.input.placeholder = Localize("signup.input.username.placeholder", table: Table.signUp)
    return textField
  }()
  
  let emailTextField: InputTextField = {
    let textField = InputTextField()
    textField.input.autocapitalizationType = .none
    textField.input.keyboardType = .emailAddress
    textField.input.textContentType = .emailAddress
    textField.input.returnKeyType = .next
    textField.title = Localize("signup.input.email.title", table: Table.signUp)
    textField.input.placeholder = Localize("signup.input.email.placeholder", table: Table.signUp)
    return textField
  }()
  
  let passwordTextField: InputTextField = {
    let textField = InputTextField()
    textField.input.isSecureTextEntry = true
    textField.input.textContentType = .password
    textField.input.returnKeyType = .join
    textField.title = Localize("signup.input.password.title", table: Table.signUp)
    textField.input.placeholder = Localize("signup.input.password.placeholder", table: Table.signUp)
    return textField
  }()

  let signUpButton: FullWidthButton = {
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
  
  func set(_ error: RegisterUserError?) {
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
  }
  
  override func setupConstraints() {
    scrollView.contentInset = UIEdgeInsets(top: Margin.huge, left: 0, bottom: 0, right: 0)
    
    signUpButton.snp.makeConstraints { make in
      make.left.equalTo(self).offset(Margin.medium)
      make.right.equalTo(self).offset(-Margin.medium)
      make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-Margin.medium)
      make.height.equalTo(ViewLayout.signInButtonHeight)
    }
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalTo(self)
        .inset(UIEdgeInsetsMake(0, 0, ViewLayout.scrollViewBottomSpace, 0))
    }
    
    stackView.snp.makeConstraints { make in
      make.edges.equalTo(scrollView)
        .inset(UIEdgeInsetsMake(0, Margin.medium, 0, Margin.medium))
    }
    
    [usernameTextField, emailTextField, passwordTextField].forEach { input in
      input.snp.makeConstraints { make in
        make.left.equalTo(self).offset(Margin.medium)
        make.right.equalTo(self).offset(-Margin.medium)
      }
    }
  }
}

