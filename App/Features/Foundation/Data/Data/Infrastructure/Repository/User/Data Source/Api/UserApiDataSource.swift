import Domain
import RxSwift
import Moya
import RxMoya

struct UserApiDataSource: UserDataSource {
  
  private let provider: MoyaProvider<UserService>
  private let errorAdapter: RegisterUserErrorAdapter
  
  init(provider: MoyaProvider<UserService>,
       errorAdapter: RegisterUserErrorAdapter)
  {
    self.provider = provider
    self.errorAdapter = errorAdapter
  }
  
  func register(with credentials: UserCredentials) -> Completable {
    return provider.rx
      .request(.register(credentials))
      .filterSuccessfulStatusCodes()
      .map(EmptyResponse.self, errorAdapter.make)
      .asCompletable()
  }
}
