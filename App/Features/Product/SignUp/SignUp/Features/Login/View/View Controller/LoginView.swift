import UI
import SnapKit
import RxSwift

private struct ViewLayout {
  static let scrollViewBottomSpace = CGFloat(80)
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
    input.autocorrectionType = .no
    input.textContentType = .username
    input.returnKeyType = .next
    input.placeholder = Localize("login.input.username.placeholder", table: Table.login)
    return input
  }()
  
  let passwordInput: Input = {
    let input = Input()
    input.isSecureTextEntry = true
    input.textContentType = .password
    input.returnKeyType = .done
    input.placeholder = Localize("login.input.password.placeholder", table: Table.login)
    return input
  }()
  
  let signInButton: FullWidthButton = {
    let button = FullWidthButton()
    let title = Localize("login.button.signin.title", Table.login).uppercased()
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
  
  @discardableResult
  override func resignFirstResponder() -> Bool {
    usernameInput.resignFirstResponder()
    passwordInput.resignFirstResponder()
    return super.resignFirstResponder()
  }
  
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
    }
    
    Keyboard.subscribe(to: [.willShow, .willHide]).subscribe(onNext: { keyboard in
      self.signInButton.snp.remakeConstraints { make in
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
      
      UIView.animate(withDuration: keyboard.animationDuration, delay: 0, options: .curveEaseIn , animations: { [weak self] in
        self?.signInButton.radiusDisabled = keyboard.event == .willHide ? false : true
        self?.layoutIfNeeded()
      })
      
    }).disposed(by: bag)
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalTo(self)
        .inset(UIEdgeInsetsMake(0, 0, ViewLayout.scrollViewBottomSpace, 0))
    }
    
    stackView.snp.makeConstraints { make in
      make.top.equalTo(scrollView).offset(Margin.medium)
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
