import RxSwift

public protocol AuthenticateUseCase {
  func execute(with credentials: BasicCredentials) -> Completable
}
