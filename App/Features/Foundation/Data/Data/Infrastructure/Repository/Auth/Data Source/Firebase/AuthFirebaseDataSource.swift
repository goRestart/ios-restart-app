import Domain
import RxSwift

struct AuthFirebaseDataSource: AuthDataSource {
  
  private let signInUserFirebaseAction: SignInUserFirebaseAction
  
  init(signInUserFirebaseAction: SignInUserFirebaseAction) {
    self.signInUserFirebaseAction = signInUserFirebaseAction
  }
  
  func authenticate(with credentials: BasicCredentials) -> Completable {
    return signInUserFirebaseAction.authenticate(with: credentials)
  }
}
