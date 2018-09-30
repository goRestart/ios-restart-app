import Core

// MARK: - User

extension Assembly {
  public var userRepository: UserRepository {
    return UserRepository(
      apiDataSource: apiDataSource
    )
  }
  private var apiDataSource: UserDataSource {
    return UserApiDataSource(
      registerUser: registerUserAction
    )
  }
  
  // MARK: - Action
  
  private var registerUserAction: RegisterUserAction {
    return RegisterUserAction(
      provider: moyaProvider(),
      errorAdapter: registerUserErrorAdapter)
  }
  
  private var registerUserErrorAdapter: RegisterUserErrorAdapter {
    return RegisterUserErrorAdapter()
  }
}
