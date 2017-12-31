import UI
import SnapKit

private struct ViewLayout {
  static let signInButtonHeight = CGFloat(56)
  static let inputHeight = CGFloat(48)
}

final class LoginView: View {
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    return scrollView
  }()
  
  let usernameInput: Input = {
    let input = Input()
    input.autocapitalizationType = .none
    input.textContentType = .username
    input.returnKeyType = .next
    input.placeholder = Localize("login.input.username.placeholder", table: Table.signUp)
    return input
  }()
  
  let passwordInput: Input = {
    let input = Input()
    input.isSecureTextEntry = true
    input.textContentType = .password
    input.returnKeyType = .join
    input.placeholder = Localize("login.input.password.placeholder", table: Table.signUp)
    return input
  }()
  
  let signInButton: FullWidthButton = {
    let button = FullWidthButton()
    let title = Localize("login.button.signin.title", Table.signUp).uppercased()
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
    stackView.addArrangedSubview(usernameInput)
    stackView.addArrangedSubview(passwordInput)
    
    scrollView.addSubview(stackView)
    
    addSubview(scrollView)
    addSubview(signInButton)
  }
  
  override func setupConstraints() {
    signInButton.snp.makeConstraints { make in
      make.left.equalTo(self).offset(Margin.medium)
      make.right.equalTo(self).offset(-Margin.medium)
      make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-Margin.medium)
      make.height.equalTo(ViewLayout.signInButtonHeight)
    }
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalTo(self)
        .inset(UIEdgeInsetsMake(0, 0, ViewLayout.signInButtonHeight, 0))
    }
    
    stackView.snp.makeConstraints { make in
      make.centerY.equalTo(scrollView)
    }
    
    [usernameInput, passwordInput].forEach { input in
      input.snp.makeConstraints { make in
        make.leading.equalTo(self).offset(Margin.medium)
        make.trailing.equalTo(self).offset(-Margin.medium)
        make.height.equalTo(ViewLayout.inputHeight)
      }
    }
  }
}
