import Domain
import Core
import RxSwift

public struct AuthRepository {
  
  private let firebaseDataSource: AuthDataSource
  
  init(firebaseDataSource: AuthDataSource) {
    self.firebaseDataSource = firebaseDataSource
  }
  
  public func authenticate(with credentials: BasicCredentials) -> Completable {
    return firebaseDataSource.authenticate(with: credentials)
  }
}
