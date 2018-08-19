import Core

// MARK: - User

extension Assembly {
  public var userRepository: UserRepository {
    return UserRepository(
      firebaseDataSource: userFirebaseDataSource
    )
  }
  private var userFirebaseDataSource: UserDataSource {
    return UserFirebaseDataSource(
      registerUserFirebaseAction: registerUserFirebaseAction
    )
  }
  
  // MARK: - Action
  
  private var registerUserFirebaseAction: RegisterUserFirebaseAction {
    return RegisterUserFirebaseAction(
      errorAdapter: registerUserFirebaseErrorAdapter
    )
  }
  
  private var registerUserFirebaseErrorAdapter: RegisterUserFirebaseErrorAdapter {
    return RegisterUserFirebaseErrorAdapter()
  }
}
