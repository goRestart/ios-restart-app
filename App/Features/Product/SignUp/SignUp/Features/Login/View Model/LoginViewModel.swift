import Application
import RxSwift
import Domain

private struct LoginViewModelConstraints {
  static let minUsernameLenght = 3
  static let minPasswordLenght = 6
}

struct LoginViewModel: LoginViewModelIO, LoginViewModelInput, LoginViewModelOutput {
 
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
  var isLoggingIn = Variable<Bool>(false)
  
  var signUpEnabled: Observable<Bool> {
    return Observable.combineLatest(
    username.asObservable(), password.asObservable()) { username, password in
      return username.count >= LoginViewModelConstraints.minUsernameLenght &&
        password.count >= LoginViewModelConstraints.minPasswordLenght
    }
  }

  var userInteractionDisabled: Observable<Bool> {
    return isLoggingIn.asObservable().map { !$0 }
  }
  
  // MARK: - Input
  
  func signUpButtonPressed() {
    isLoggingIn.value = true
    
    let credentials = BasicCredentials(
      username: username.value,
      password: password.value
    )
    
    authenticate.execute(with: credentials).subscribe(onCompleted: {
      print("Welcome :)")
    }) { error in
      print("Error :(")
      self.isLoggingIn.value = false
    }.disposed(by: bag)
  }
}
