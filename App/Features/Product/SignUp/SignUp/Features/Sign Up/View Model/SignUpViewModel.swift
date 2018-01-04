import Application
import RxSwift
import Domain
import Core

private struct LoginViewModelConstraints {
  static let minUsernameLenght = 3
  static let minPasswordLenght = 6
}

struct SignUpViewModel: SignUpViewModelType, SignUpViewModelInput, SignUpViewModelOutput {
  
  var input: SignUpViewModelInput { return self }
  var output: SignUpViewModelOutput { return self }
  
  private let bag = DisposeBag()
  private let emailValidator: EmailValidator
  
  init(emailValidator: EmailValidator) {
    self.emailValidator = emailValidator
  }

  // MARK: - Output
  
  var username = Variable<String>("")
  var password = Variable<String>("")
  var email = Variable<String>("")
  var state = Variable<SignUpState>(.idle)
  
  var signUpEnabled: Observable<Bool> {
    return Observable.combineLatest(
    username.asObservable(), email.asObservable(), password.asObservable()) { username, email, password in
      return username.count >= LoginViewModelConstraints.minUsernameLenght &&
        self.emailValidator.validate(email) &&
        password.count >= LoginViewModelConstraints.minPasswordLenght
    }
  }
  
  var userInteractionEnabled: Observable<Bool> {
    return state.asObservable().map { $0 == .idle }
  }
  
  // MARK: - Input
  
  func signInButtonPressed() {
    state.value = .loading
    
    let credentials = UserCredentials(
      username: username.value,
      email: email.value,
      password: password.value
    )
    
    print("Creating user with \(credentials)")
  }
}

