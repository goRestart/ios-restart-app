import Application
import Domain
import RxSwift
import RxCocoa

private enum LoginViewModelConstraints {
  static let minUsernameLenght = 3
  static let minPasswordLenght = 6
}

struct LoginViewModel: LoginViewModelType, LoginViewModelInput, LoginViewModelOutput {

  var input: LoginViewModelInput { return self }
  var output: LoginViewModelOutput { return self }
  
  private let bag = DisposeBag()
  private let authenticate: AuthenticateUseCase
  
  init(authenticate: AuthenticateUseCase) {
    self.authenticate = authenticate
  }
  
  // MARK: - Output
  
  private let stateRelay = BehaviorRelay<LoginState>(value: .idle)
  var state: Driver<LoginState> { return stateRelay.asDriver(onErrorJustReturn: .idle) }
  
  var signInEnabled: Driver<Bool> {
    return Observable.combineLatest(
    usernameRelay, passwordRelay) { username, password in
      return username.count >= LoginViewModelConstraints.minUsernameLenght &&
        password.count >= LoginViewModelConstraints.minPasswordLenght
    }.asDriver(onErrorJustReturn: false)
  }

  var userInteractionEnabled: Driver<Bool> {
    return stateRelay.map { $0 == .idle }
      .asDriver(onErrorJustReturn: false)
  }
  
  // MARK: - Input
  
  private let usernameRelay = BehaviorRelay<String>(value: "")
  private let passwordRelay = BehaviorRelay<String>(value: "")
  
  func onChange(username: String) {
    usernameRelay.accept(username)
  }
  
  func onChange(password: String) {
    passwordRelay.accept(password)
  }
  
  func signUpButtonPressed() {
    stateRelay.accept(.loading)
    
    let authentication = Observable
      .combineLatest(usernameRelay, passwordRelay)
      .map(BasicCredentials.init)
      .flatMap(authenticate.execute)
      .asCompletable()
    
    authentication.subscribe(onCompleted: {
      print("Completed")
    }) { error in
      print("Error = \(error)")
      self.stateRelay.accept(.idle)
    }.disposed(by: bag)
  }
}
