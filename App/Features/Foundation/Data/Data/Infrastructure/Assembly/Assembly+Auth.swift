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
    return AuthTokenStorage(
      keychain: keychain
    )
  }
  
  private var keychain: Keychaneable {
    let keychain = KeychainAccess.Keychain(service: "com.restart.app")
    return Keychain(
      keychain: keychain
    )
  }
}
