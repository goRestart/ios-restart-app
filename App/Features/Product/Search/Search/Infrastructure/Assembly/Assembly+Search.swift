import Domain
import Core
import Application

extension Assembly {
  public var searchView: SearchView {
    let view = SearchView(
      viewModel: viewModel
    )
    return view
  }
  
  private var viewModel: SearchViewModelType {
    return SearchViewModel(
      searchGames: searchGames
    )
  }
  
  private var searchGames: SearchGamesUseCase {
    return SearchGames()
  }
}
