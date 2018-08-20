import Domain
import RxSwift
import FirebaseAuth

struct SignInUserFirebaseAction {
  
  private let errorAdapter: SignInUserFirebaseErrorAdapter
  
  init(errorAdapter: SignInUserFirebaseErrorAdapter) {
    self.errorAdapter = errorAdapter
  }
  
  func authenticate(with credentials: BasicCredentials) -> Completable {
    return Auth.auth().rx
      .signIn(email: credentials.username, password: credentials.password)
      .catchError { error in
        throw try self.errorAdapter.make(error)
      }.asCompletable()
  }
}
