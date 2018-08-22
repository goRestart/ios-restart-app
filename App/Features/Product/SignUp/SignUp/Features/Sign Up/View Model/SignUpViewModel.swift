import Application
import RxSwift
import Domain
import Core

private enum LoginViewModelConstraints {
  static let minUsernameLenght = 3
  static let minPasswordLenght = 6
}

struct SignUpViewModel: SignUpViewModelType, SignUpViewModelInput, SignUpViewModelOutput {
  
  var input: SignUpViewModelInput { return self }
  var output: SignUpViewModelOutput { return self }
  
  private let bag = DisposeBag()
  private let emailValidator: EmailValidator
  private let registerUser: RegisterUserUseCase
  
  init(emailValidator: EmailValidator,
       registerUser: RegisterUserUseCase)
  {
    self.emailValidator = emailValidator
    self.registerUser = registerUser
  }
  
  // MARK: - Output
  
  var username = BehaviorSubject<String>(value: "")
  var password = BehaviorSubject<String>(value: "")
  var email = BehaviorSubject<String>(value: "")
  var state = PublishSubject<SignUpState>()
  var error = PublishSubject<RegisterUserError?>()
  
  var signUpEnabled: Observable<Bool> {
    return Observable.combineLatest(
    username.asObservable(), email.asObservable(), password.asObservable()) {
      username, email, password in
      return username.count >= LoginViewModelConstraints.minUsernameLenght &&
        password.count >= LoginViewModelConstraints.minPasswordLenght &&
        self.emailValidator.validate(email)
    }
  }
  
  var userInteractionEnabled: Observable<Bool> {
    return state.asObservable().map { $0 == .idle }
  }
  
  // MARK: - Input
  
  func signInButtonPressed() {
    state.onNext(.loading)
    
    let credentials = UserCredentials(
      username: try! username.value(),
      email: try! email.value(),
      password: try! password.value()
    )
    
    registerUser.execute(with: credentials)
      .subscribe(onCompleted: {
        print("User created correctly ✅") // TODO: Handle user creation
      }) { error in
        self.handle(error)
      }.disposed(by: bag)
  }
  
  private func handle(_ error: Error) {
    guard let error = error as? RegisterUserError else {
      // TODO: Show generic error
      return
    }
    self.error.onNext(error)
    self.state.onNext(.idle)
  }
}
