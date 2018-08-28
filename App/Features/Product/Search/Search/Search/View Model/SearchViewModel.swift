import RxSwift
import Domain

struct SearchViewModel: SearchViewModelType, SearchViewModelOutput {

  var output: SearchViewModelOutput { return self }
  
  private let resultsSubject = PublishSubject<[GameSearchSuggestion]>()
  var results: Observable<[GameSearchSuggestion]> { return resultsSubject }
  
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
      .bind(to: resultsSubject)
      .disposed(by: bag)
  }
}
