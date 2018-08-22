import Application
import RxSwift
import Domain

private struct LoginViewModelConstraints {
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
  
  var username = BehaviorSubject<String>(value: "")
  var password = BehaviorSubject<String>(value: "")
  var state = BehaviorSubject<LoginState>(value: .idle)
  
  var signInEnabled: Observable<Bool> {
    return Observable.combineLatest(
    username.asObservable(), password.asObservable()) { username, password in
      return username.count >= LoginViewModelConstraints.minUsernameLenght &&
        password.count >= LoginViewModelConstraints.minPasswordLenght
    }
  }

  var userInteractionEnabled: Observable<Bool> {
    return .just(
      try! state.value() == .idle
    )
  }
  
  // MARK: - Input
  
  func signUpButtonPressed() {
    state.onNext(.loading)
    
    let credentials = BasicCredentials(
      username: try! username.value(),
      password: try! password.value()
    )
    
    authenticate.execute(with: credentials).subscribe(onCompleted: {
      print("Welcome :)")
    }) { error in
      print("Error :(")
      self.state.onNext(.idle)
    }.disposed(by: bag)
  }
}
