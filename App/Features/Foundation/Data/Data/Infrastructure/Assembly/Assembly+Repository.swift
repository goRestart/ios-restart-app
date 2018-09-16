import Core

// MARK: - Product

extension Assembly {
  public var productRepository: ProductRepository {
    return ProductRepository(
      algoliaDataSource: productAlgoliaDataSource,
      apiDataSource: productApiDataSource
    )
  }
  
  private var productAlgoliaDataSource: ProductExtrasDataSource {
    return ProductAlgoliaDataSource(
      getProductExtrasAlgoliaAction: getProductExtrasAlgoliaAction
    )
  }
  
  private var productApiDataSource: ProductDataSource {
    return ProductApiDataSource(
      provider: moyaProvider()
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

// MARK: - Product Draft

extension Assembly {
  public var productDraftRepository: ProductDraftRepository {
    return ProductDraftRepository(
      inMemoryDataSource: productDraftInMemoryDataSource
    )
  }
  
  private var productDraftInMemoryDataSource: ProductDraftDataSource {
    return ProductDraftInMemoryDataSource.shared
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
