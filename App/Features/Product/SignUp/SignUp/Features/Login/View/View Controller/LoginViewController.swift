import UIKit
import RxCocoa
import RxSwift
import UI

public final class LoginViewController: ViewController {
 
  var viewModel: LoginViewModelType!
  
  private let loginView = LoginView()
  
  public override func loadView() {
    self.view = loginView
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override public func bindViewModel() {
    loginView.usernameInput.rx.value
      .orEmpty
      .bind(to: viewModel.output.username)
      .disposed(by: bag)
    
    loginView.passwordInput.rx.value
      .orEmpty
      .bind(to: viewModel.output.password)
      .disposed(by: bag)
 
    loginView.usernameInput.rx
      .controlEvent(.editingDidEndOnExit)
      .subscribe(onNext: { [weak self] _ in
        self?.loginView.passwordInput.becomeFirstResponder()
      })
      .disposed(by: bag)
    
    viewModel.output.userInteractionEnabled
      .bind(to: loginView.usernameInput.rx.isUserInteractionEnabled)
      .disposed(by: bag)
    
    viewModel.output.userInteractionEnabled
      .bind(to: loginView.passwordInput.rx.isUserInteractionEnabled)
      .disposed(by: bag)
    
    viewModel.output.state
      .asObservable()
      .map { $0 == .loading}
      .bind(to: loginView.signInButton.rx.isLoading)
      .disposed(by: bag)
    
    viewModel.output.signUpEnabled
      .asObservable()
      .bind(to: loginView.signInButton.rx.isEnabled)
      .disposed(by: bag)
    
    viewModel.output.userInteractionEnabled
      .bind(to: loginView.signInButton.rx.isUserInteractionEnabled)
      .disposed(by: bag)
    
    loginView.signInButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        self?.viewModel.input.signUpButtonPressed()
      })
      .disposed(by: bag)
  }
}
