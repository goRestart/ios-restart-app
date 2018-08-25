import Core

// MARK: - Product

extension Assembly {
  public var productRepository: ProductRepository {
    return ProductRepository(
      algoliaDataSource: productAlgoliaDataSource
    )
  }
  
  private var productAlgoliaDataSource: ProductDataSource {
    return ProductAlgoliaDataSource(
      getProductExtrasAlgoliaAction: getProductExtrasAlgoliaAction
    )
  }
  
  // MARK: - Actions
  
  private var getProductExtrasAlgoliaAction: GetProductExtrasAlgoliaAction {
    return GetProductExtrasAlgoliaAction(
      productExtrasIndex: AlgoliaIndice.productExtras,
      productExtraMapper: productExtraMapper
    )
  }
  
  // MARK: - Mapper
  
  private var productExtraMapper: ProductExtraMapper {
    return ProductExtraMapper()
  }
}

// MARK: - Game

extension Assembly: GameSuggestionMapperProvider {
  public var gameRepository: GameRepository {
    return GameRepository(
      algoliaDataSource: gameAlgoliaDataSource
    )
  }
  
  private var gameAlgoliaDataSource: GameDataSource {
    return GameAlgoliaDataSource(
      gamesIndex: AlgoliaIndice.games,
      gameSuggestionMapperProvider: self
    )
  }
  
  // MARK: - GameSuggestionMapperProvider
  
  func gameSuggestionMapper(with query: String) -> GameSuggestionMapper {
    return GameSuggestionMapper(query: query)
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
