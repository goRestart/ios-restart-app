import RxSwift
import Domain

struct SearchViewModel: SearchViewModelType, SearchViewModelOutput {

  var output: SearchViewModelOutput { return self }
 
  var results = BehaviorSubject<[GameSearchSuggestion]>(value: [])
  
  private let bag = DisposeBag()
  private let searchGames: SearchGamesUseCase
  
  init(searchGames: SearchGamesUseCase) {
    self.searchGames = searchGames
  }
 
  // MARK: - Output
  
  func bind(to query: Observable<String>) {
    query.flatMapLatest { query in
      self.searchGames.execute(with: query)
    }.catchErrorJustReturn([])
      .bind(to: results)
      .disposed(by: bag)
  }
}
