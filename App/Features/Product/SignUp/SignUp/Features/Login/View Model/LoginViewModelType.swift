import RxSwift

enum LoginState {
  case idle
  case loading
}

protocol LoginViewModelInput {
  var username: BehaviorSubject<String> { get }
  var password: BehaviorSubject<String> { get }
  
  func signUpButtonPressed()
}

protocol LoginViewModelOutput {
  var state: Observable<LoginState> { get }
  
  var userInteractionEnabled: Observable<Bool> { get }
  var signInEnabled: Observable<Bool> { get }
}

protocol LoginViewModelType {
  var input: LoginViewModelInput { get }
  var output: LoginViewModelOutput { get }
}
