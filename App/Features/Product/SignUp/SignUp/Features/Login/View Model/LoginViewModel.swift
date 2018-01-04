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
  
  var username = Variable<String>("")
  var password = Variable<String>("")
  var state = Variable<LoginState>(.idle)
  
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
  
  func signUpButtonPressed() {
    state.value = .loading
    
    let credentials = BasicCredentials(
      username: username.value,
      password: password.value
    )
    
    authenticate.execute(with: credentials).subscribe(onCompleted: {
      print("Welcome :)")
    }) { error in
      print("Error :(")
      self.state.value = .idle
    }.disposed(by: bag)
  }
}
