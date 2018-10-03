import Core

// MARK: - Auth

extension Assembly {
  public var authRepository: AuthRepository {
    return AuthRepository(
      firebaseDataSource: authApiDataSource
    )
  }
  private var authApiDataSource: AuthDataSource {
    return AuthApiDataSource(
      signInUserAction: signInUserAction
    )
  }
  
  // MARK: - Action
  
  private var signInUserAction: SignInUserAction {
    return SignInUserAction(
      provider: moyaProvider(),
      errorAdapter: signInUserErrorAdapter,
      authTokenStorage: authTokenStorage
    )
  }
  
  private var signInUserErrorAdapter: SignInUserErrorAdapter {
    return SignInUserErrorAdapter()
  }
}

// MARK: - Auth token

import KeychainAccess

extension Assembly {
  var authTokenStorage: AuthTokenStorage {
    let keychain = Keychain(service: "com.restart.app")
    return AuthTokenStorage(
      keychain: keychain
    )
  }
}
