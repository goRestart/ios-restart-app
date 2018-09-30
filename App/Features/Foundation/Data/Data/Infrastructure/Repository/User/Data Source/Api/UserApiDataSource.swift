import Domain
import RxSwift

struct UserApiDataSource: UserDataSource {
  
  private let registerUser: RegisterUserAction
  
  init(registerUser: RegisterUserAction) {
    self.registerUser = registerUser
  }
  
  func register(with credentials: UserCredentials) -> Completable {
    return registerUser.execute(with: credentials)
  }
}
