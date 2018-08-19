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
  var username: BehaviorSubject<String> { get }
  var email: BehaviorSubject<String> { get }
  var password: BehaviorSubject<String> { get }
  var state: BehaviorSubject<SignUpState> { get }
  var error: BehaviorSubject<RegisterUserError?> { get }
  
  var userInteractionEnabled: Observable<Bool> { get }
  var signUpEnabled: Observable<Bool> { get }
}

protocol SignUpViewModelType {
  var input: SignUpViewModelInput { get }
  var output: SignUpViewModelOutput { get }
}
