import RxSwift

protocol LoginViewModelInput {
  func signUpButtonPressed()
}

protocol LoginViewModelOutput {
  var username: Variable<String> { get }
  var password: Variable<String> { get }
  var isLoggingIn: Variable<Bool> { get }
  
  var userInteractionDisabled: Observable<Bool> { get }
  var signUpEnabled: Observable<Bool> { get }
}

protocol LoginViewModelType {
  var input: LoginViewModelInput { get }
  var output: LoginViewModelOutput { get }
}
