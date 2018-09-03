import RxSwift
import RxCocoa

enum LoginState {
  case idle
  case loading
}

protocol LoginViewModelInput {
  func signUpButtonPressed()
  func onChange(username: String)
  func onChange(password: String)
}

protocol LoginViewModelOutput {
  var state: Driver<LoginState> { get }
  
  var userInteractionEnabled: Driver<Bool> { get }
  var signInEnabled: Driver<Bool> { get }
}

protocol LoginViewModelType {
  var input: LoginViewModelInput { get }
  var output: LoginViewModelOutput { get }
}
