import Core

// MARK: - Auth

extension Assembly {
  public var authRepository: AuthRepository {
    return AuthRepository(
      apiDataSource: authApiDataSource
    )
  }
  
  private var authApiDataSource: AuthDataSource {
    return AuthApiDataSource(
      provider: moyaProvider(),
      errorAdapter: authErrorAdapter
    )
  }
  
  private var authErrorAdapter: AuthenticateErrorAdapter {
    return AuthenticateErrorAdapter()
  }
}

// MARK: - User

extension Assembly {
  public var userRepository: UserRepository {
    return UserRepository(
      apiDataSource: userApiDataSource
    )
  }
  
  private var userApiDataSource: UserDataSource {
    return UserApiDataSource(
      provider: moyaProvider(),
      errorAdapter: userErrorAdapter
    )
  }
  
  private var userErrorAdapter: RegisterUserErrorAdapter {
    return RegisterUserErrorAdapter()
  }
}

// MARK: - Game

extension Assembly {
  public var gameRepository: GameRepository {
    return GameRepository(
      apiDataSource: gameApiDataSource
    )
  }
  
  private var gameApiDataSource: GameDataSource {
    return GameApiDataSource(
      provider: moyaProvider()
    )
  }
}
