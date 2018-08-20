import Core

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
