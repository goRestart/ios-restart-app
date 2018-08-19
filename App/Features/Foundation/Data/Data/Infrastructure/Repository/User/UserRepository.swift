import Domain
import RxSwift

public struct UserRepository {
  
  private let firebaseDataSource: UserDataSource
  
  init(firebaseDataSource: UserDataSource) {
    self.firebaseDataSource = firebaseDataSource
  }
  
  public func register(with credentials: UserCredentials) -> Completable {
    return firebaseDataSource.register(with: credentials)
  }
}
