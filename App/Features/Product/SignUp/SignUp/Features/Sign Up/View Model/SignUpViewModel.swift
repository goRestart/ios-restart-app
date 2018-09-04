import Application
import Domain
import Core
import RxSwift
import RxCocoa

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
  
  private let stateSubject = PublishSubject<SignUpState>()
  var state: Driver<SignUpState> {
    return stateSubject.asDriver(onErrorJustReturn: .idle)
  }
  
  private let errorSubject = PublishSubject<RegisterUserError?>()
  var error: Driver<RegisterUserError?> {
    return errorSubject.asDriver(onErrorJustReturn: nil)
  }

  var signUpEnabled: Driver<Bool> {
    return Observable.combineLatest(usernameSubject, emailSubject, passwordSubject) {
      username, email, password in
      return username.count >= LoginViewModelConstraints.minUsernameLenght &&
        password.count >= LoginViewModelConstraints.minPasswordLenght &&
        self.emailValidator.validate(email)
    }.asDriver(onErrorJustReturn: false)
  }
  
  var userInteractionEnabled: Driver<Bool> {
    return state.asObservable().map { $0 == .idle }
      .asDriver(onErrorJustReturn: false)
  }
  
  // MARK: - Input
  
  private let usernameSubject = BehaviorSubject<String>(value: "")
  private let passwordSubject = BehaviorSubject<String>(value: "")
  private let emailSubject = BehaviorSubject<String>(value: "")
  
  func onChange(username: String) {
    usernameSubject.onNext(username)
  }
  
  func onChange(email: String) {
    emailSubject.onNext(email)
  }
  
  func onChange(password: String) {
    passwordSubject.onNext(password)
  }
  
  func signInButtonPressed() {
    stateSubject.onNext(.loading)
    
    let register = Observable
      .combineLatest(usernameSubject, emailSubject, passwordSubject)
      .map(UserCredentials.init)
      .flatMap(registerUser.execute)
      .asCompletable()
    
      register.subscribe(onCompleted: {
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
    errorSubject.onNext(error)
    stateSubject.onNext(.idle)
  }
}
