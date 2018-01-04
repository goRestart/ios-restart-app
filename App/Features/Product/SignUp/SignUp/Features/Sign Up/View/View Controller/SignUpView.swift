import UI
import SnapKit

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

