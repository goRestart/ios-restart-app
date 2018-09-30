import Domain
import RxSwift

public struct UserRepository {
  
  private let apiDataSource: UserDataSource
  
  init(apiDataSource: UserDataSource) {
    self.apiDataSource = apiDataSource
  }
  
  public func register(with credentials: UserCredentials) -> Completable {
    return apiDataSource.register(with: credentials)
  }
}
