import RxSwift

enum LoginState {
  case idle
  case loading
}

protocol LoginViewModelInput {
  func signUpButtonPressed()
}

protocol LoginViewModelOutput {
  var username: Variable<String> { get }
  var password: Variable<String> { get }
  var state: Variable<LoginState> { get }
  
  var userInteractionEnabled: Observable<Bool> { get }
  var signUpEnabled: Observable<Bool> { get }
}

protocol LoginViewModelType {
  var input: LoginViewModelInput { get }
  var output: LoginViewModelOutput { get }
}
