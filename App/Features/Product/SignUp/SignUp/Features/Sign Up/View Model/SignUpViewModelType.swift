import Domain
import RxSwift
import RxCocoa

enum SignUpState {
  case idle
  case loading
}

protocol SignUpViewModelInput {
  func onChange(username: String)
  func onChange(email: String)
  func onChange(password: String)
  func signInButtonPressed()
}

protocol SignUpViewModelOutput {
  var state: Driver<SignUpState> { get }
  var error: Driver<RegisterUserError?> { get }
  
  var userInteractionEnabled: Driver<Bool> { get }
  var signUpEnabled: Driver<Bool> { get }
}

protocol SignUpViewModelType {
  var input: SignUpViewModelInput { get }
  var output: SignUpViewModelOutput { get }
}
