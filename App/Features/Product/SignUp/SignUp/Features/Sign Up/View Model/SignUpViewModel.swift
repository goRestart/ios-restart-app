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
  
  private let stateRelay = PublishRelay<SignUpState>()
  var state: Driver<SignUpState> {
    return stateRelay.asDriver(onErrorJustReturn: .idle)
  }
  
  private let errorRelay = PublishRelay<RegisterUserError?>()
  var error: Driver<RegisterUserError?> {
    return errorRelay.asDriver(onErrorJustReturn: nil)
  }

  var signUpEnabled: Driver<Bool> {
    return Observable.combineLatest(usernameRelay, emailRelay, passwordRelay) {
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
  
  private let usernameRelay = BehaviorRelay<String>(value: "")
  private let passwordRelay = BehaviorRelay<String>(value: "")
  private let emailRelay = BehaviorRelay<String>(value: "")
  
  func onChange(username: String) {
    usernameRelay.accept(username)
  }
  
  func onChange(email: String) {
    emailRelay.accept(email)
  }
  
  func onChange(password: String) {
    passwordRelay.accept(password)
  }
  
  func signInButtonPressed() {
    stateRelay.accept(.loading)
    
    let register = Observable
      .combineLatest(usernameRelay, emailRelay, passwordRelay)
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
    errorRelay.accept(error)
    stateRelay.accept(.idle)
  }
}
