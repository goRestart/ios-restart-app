import RxSwift
import FirebaseAuth

extension Reactive where Base: Auth {
  func signIn(with customToken: String) -> Completable {
    return Completable.create { event in
      Auth.auth().signIn(withCustomToken: customToken) { result, error in
        if let _ = result {
          event(.completed)
        }
        if let error = error {
          event(.error(error))
        }
      }
      return Disposables.create()
    }
  }
  
  func signIn(email: String, password: String) -> Single<AuthDataResult> {
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
