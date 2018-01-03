import Domain
import RxSwift
import Moya
import RxMoya

struct AuthApiDataSource: AuthDataSource {
  
  private let provider: MoyaProvider<AuthService>
  private let errorAdapter: AuthenticateErrorAdapter

  init(provider: MoyaProvider<AuthService>,
       errorAdapter: AuthenticateErrorAdapter)
  {
    self.provider = provider
    self.errorAdapter = errorAdapter
  }

  func authenticate(with credentials: BasicCredentials) -> Single<AuthToken> {
    return provider.rx
      .request(.authenticate(credentials))
      .map(AuthToken.self, errorAdapter.make)
  }
}
