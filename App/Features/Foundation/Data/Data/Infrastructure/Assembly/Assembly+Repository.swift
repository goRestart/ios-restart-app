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

// MARK: - Image

extension Assembly {
  public var imageRepository: ImageRepository {
    return ImageRepository(
      apiDataSource: imageApiDataSource
    )
  }
  
  private var imageApiDataSource: ImageDataSource {
    return ImageApiDataSource(
      provider: moyaProvider()
    )
  }
}
