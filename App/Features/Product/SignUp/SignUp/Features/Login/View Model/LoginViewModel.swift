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
  
  private let stateSubject = BehaviorSubject<LoginState>(value: .idle)
  var state: Observable<LoginState> { return stateSubject }
  
  var signInEnabled: Observable<Bool> {
    return Observable.combineLatest(
    username.asObservable(), password.asObservable()) { username, password in
      return username.count >= LoginViewModelConstraints.minUsernameLenght &&
        password.count >= LoginViewModelConstraints.minPasswordLenght
    }
  }

  var userInteractionEnabled: Observable<Bool> {
    return state.asObservable().map { $0 == .idle }
  }
  
  // MARK: - Input
  
  var username = BehaviorSubject<String>(value: "")
  var password = BehaviorSubject<String>(value: "")
  
  func signUpButtonPressed() {
    stateSubject.onNext(.loading)
    
    let credentials = BasicCredentials(
      username: try! username.value(),
      password: try! password.value()
    )

    authenticate.execute(with: credentials).subscribe(onCompleted: {
      print("Welcome :)")
    }) { error in
      print("Error :(")
      self.stateSubject.onNext(.idle)
    }.disposed(by: bag)
  }
}
