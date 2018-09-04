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
  private let authenticate: Authenticate
  
  init(authenticate: Authenticate) {
    self.authenticate = authenticate
  }
  
  // MARK: - Output
  
  private let stateSubject = BehaviorSubject<LoginState>(value: .idle)
  var state: Driver<LoginState> { return stateSubject.asDriver(onErrorJustReturn: .idle) }
  
  var signInEnabled: Driver<Bool> {
    return Observable.combineLatest(
    usernameSubject, passwordSubject) { username, password in
      return username.count >= LoginViewModelConstraints.minUsernameLenght &&
        password.count >= LoginViewModelConstraints.minPasswordLenght
    }.asDriver(onErrorJustReturn: false)
  }

  var userInteractionEnabled: Driver<Bool> {
    return state.asObservable().map { $0 == .idle }
      .asDriver(onErrorJustReturn: false)
  }
  
  // MARK: - Input
  
  private let usernameSubject = BehaviorSubject<String>(value: "")
  private let passwordSubject = BehaviorSubject<String>(value: "")
  
  func onChange(username: String) {
    usernameSubject.onNext(username)
  }
  
  func onChange(password: String) {
    passwordSubject.onNext(password)
  }
  
  func signUpButtonPressed() {
    stateSubject.onNext(.loading)
    
    let authentication = Observable
      .combineLatest(usernameSubject, passwordSubject)
      .map(BasicCredentials.init)
      .map(authenticate.execute)
      .asCompletable()
    
    authentication.subscribe(onCompleted: {
      print("Completed")
    }) { error in
      print("Error = \(error)")
      self.stateSubject.onNext(.idle)
    }.disposed(by: bag)
  }
}
