import Domain
import RxSwift

final class AuthenticateStub: AuthenticateUseCase {
  
  var responseError: AuthError?
  
  func execute(with credentials: BasicCredentials) -> Completable {
    return Completable.create { completable in
      guard let responseError = self.responseError else {
        completable(.completed)
        return Disposables.create()
      }
      completable(.error(responseError))
      return Disposables.create()
    }
  }
}
