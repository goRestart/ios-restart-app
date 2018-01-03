import Domain
import RxSwift

protocol UserDataSource {
  func register(with credentials: UserCredentials) -> Completable
}
