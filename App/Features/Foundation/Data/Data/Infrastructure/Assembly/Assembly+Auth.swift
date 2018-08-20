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
