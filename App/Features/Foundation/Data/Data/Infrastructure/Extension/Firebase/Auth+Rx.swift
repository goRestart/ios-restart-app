import RxSwift
import FirebaseAuth

extension Reactive where Base: Auth {
  public func createUser(email: String, password: String) -> Single<AuthDataResult> {
    return Single.create { event in
      Auth.auth().createUser(withEmail: email, password: password, completion: { (result, error) in
        if let result = result {
          event(.success(result))
        }
        if let error = error {
          event(.error(error))
        }
      })
      return Disposables.create()
    }
  }
  
  public func signIn(email: String, password: String) -> Single<AuthDataResult> {
    return Single.create { event in
      Auth.auth().signIn(withEmail: email, password: password, completion: { (result, error) in
        if let result = result {
          event(.success(result))
        }
        if let error = error {
          event(.error(error))
        }
      })
      return Disposables.create()
    }
  }
}
