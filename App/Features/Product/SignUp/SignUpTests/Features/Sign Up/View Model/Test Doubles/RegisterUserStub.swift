import Domain
import RxSwift

final class RegisterUserStub: RegisterUserUseCase {
  
  var responseError: RegisterUserError?
  
  func execute(with credentials: UserCredentials) -> Completable {
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
