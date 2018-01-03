import Domain
import Core
import RxSwift

public struct AuthRepository {
  
  private let apiDataSource: AuthDataSource
  
  init(apiDataSource: AuthDataSource) {
    self.apiDataSource = apiDataSource
  }
  
  public func authenticate(with credentials: BasicCredentials) -> Completable {
    return apiDataSource.authenticate(with: credentials).asCompletable()
  }
}
