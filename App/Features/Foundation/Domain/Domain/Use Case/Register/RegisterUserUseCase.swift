import RxSwift

public protocol RegisterUserUseCase {
  func execute(with credentials: UserCredentials) -> Completable
}
