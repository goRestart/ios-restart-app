import Core

// MARK: - Auth

extension Assembly {
  public var authRepository: AuthRepository {
    return AuthRepository(
      firebaseDataSource: authFirebaseDataSource
    )
  }
  private var authFirebaseDataSource: AuthDataSource {
    return AuthFirebaseDataSource(
      signInUserFirebaseAction: signInUserFirebaseAction
    )
  }
  
  // MARK: - Action
  
  private var signInUserFirebaseAction: SignInUserFirebaseAction {
    return SignInUserFirebaseAction(
      errorAdapter: signInUserFirebaseErrorAdapter
    )
  }
  
  private var signInUserFirebaseErrorAdapter: SignInUserFirebaseErrorAdapter {
    return SignInUserFirebaseErrorAdapter()
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
