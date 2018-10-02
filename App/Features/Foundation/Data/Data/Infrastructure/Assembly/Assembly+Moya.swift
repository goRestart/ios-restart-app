import Core
import Moya

extension Assembly {
  func moyaProvider<T>() -> MoyaProvider<T> {
    let plugins = [
      authTokenPlugin
    ]
    return MoyaProvider(plugins: plugins)
  }
}

// MARK: - Plugins

extension Assembly {
  private var authTokenPlugin: AuthTokenPlugin {
    return AuthTokenPlugin(
      authTokenStorage: authTokenStorage
    )
  }
}
