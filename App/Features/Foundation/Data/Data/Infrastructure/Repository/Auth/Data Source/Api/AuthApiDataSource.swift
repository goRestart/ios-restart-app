import Domain
import RxSwift

struct AuthApiDataSource: AuthDataSource {
  
  private let signInUserAction: SignInUserAction
  
  init(signInUserAction: SignInUserAction) {
    self.signInUserAction = signInUserAction
  }
  
  func authenticate(with credentials: BasicCredentials) -> Completable {
    return signInUserAction.authenticate(with: credentials)
  }
}
