import Core
import Moya

extension Assembly {
  public var authRepository: AuthRepository {
    return AuthRepository(
      apiDataSource: apiDataSource
    )
  }
  
  private var apiDataSource: AuthDataSource {
    return AuthApiDataSource(
      provider: MoyaProvider(),
      errorAdapter: errorAdapter
    )
  }
  
  private var errorAdapter: AuthenticateErrorAdapter {
    return AuthenticateErrorAdapter()
  }
}
