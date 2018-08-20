import Domain
import RxSwift

protocol AuthDataSource {
  func authenticate(with credentials: BasicCredentials) -> Completable
}
