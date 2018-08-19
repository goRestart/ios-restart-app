import Domain
import RxSwift
import FirebaseCore
import FirebaseAuth

struct UserFirebaseDataSource: UserDataSource {
  
  private let registerUserFirebaseAction: RegisterUserFirebaseAction
  
  init(registerUserFirebaseAction: RegisterUserFirebaseAction) {
    self.registerUserFirebaseAction = registerUserFirebaseAction
  }
  
  func register(with credentials: UserCredentials) -> Completable {
    return registerUserFirebaseAction.register(with: credentials)
  }
}
