import RxSwift
import Domain

enum SignUpState {
  case idle
  case loading
}

protocol SignUpViewModelInput {
  func signInButtonPressed()
}

protocol SignUpViewModelOutput {
  var username: Variable<String> { get }
  var email: Variable<String> { get }
  var password: Variable<String> { get }
  var state: Variable<SignUpState> { get }
  var error: Variable<RegisterUserError?> { get }
  
  var userInteractionEnabled: Observable<Bool> { get }
  var signUpEnabled: Observable<Bool> { get }
}

protocol SignUpViewModelType {
  var input: SignUpViewModelInput { get }
  var output: SignUpViewModelOutput { get }
}
