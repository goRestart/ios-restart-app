import RxSwift

enum LoginState {
  case idle
  case loading
}

protocol LoginViewModelInput {
  func signUpButtonPressed()
}

protocol LoginViewModelOutput {
  var username: BehaviorSubject<String> { get }
  var password: BehaviorSubject<String> { get }
  var state: BehaviorSubject<LoginState> { get }
  
  var userInteractionEnabled: Observable<Bool> { get }
  var signInEnabled: Observable<Bool> { get }
}

protocol LoginViewModelType {
  var input: LoginViewModelInput { get }
  var output: LoginViewModelOutput { get }
}
