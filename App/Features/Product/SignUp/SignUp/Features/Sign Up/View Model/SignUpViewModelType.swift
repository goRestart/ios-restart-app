import RxSwift

enum SignUpState {
  case idle
  case loading
}

protocol SignUpViewModelInput {
  func signUpButtonPressed()
}

protocol SignUpViewModelOutput {
  var username: Variable<String> { get }
  var email: Variable<String> { get }
  var password: Variable<String> { get }
  var state: Variable<SignUpState> { get }
  
  var userInteractionEnabled: Observable<Bool> { get }
  var signUpEnabled: Observable<Bool> { get }
}

protocol SignUpViewModelType {
  var input: LoginViewModelInput { get }
  var output: LoginViewModelOutput { get }
}
