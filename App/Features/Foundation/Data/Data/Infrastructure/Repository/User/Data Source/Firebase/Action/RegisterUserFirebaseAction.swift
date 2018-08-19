import Domain
import RxSwift
import FirebaseAuth

struct RegisterUserFirebaseAction {
  
  private let errorAdapter: RegisterUserFirebaseErrorAdapter
  
  init(errorAdapter: RegisterUserFirebaseErrorAdapter) {
    self.errorAdapter = errorAdapter
  }
  
  func register(with credentials: UserCredentials) -> Completable {
    return Auth.auth().rx
      .createUser(email: credentials.email, password: credentials.password)
      .catchError { error in
        throw try self.errorAdapter.make(error)
      }.asCompletable()
  }
}
