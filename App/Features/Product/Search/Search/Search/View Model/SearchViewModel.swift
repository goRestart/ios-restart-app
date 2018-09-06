import Domain
import RxSwift
import RxCocoa

struct SearchViewModel: SearchViewModelType, SearchViewModelOutput {

  var output: SearchViewModelOutput { return self }
  
  private let resultsRelay = PublishRelay<[GameSearchSuggestion]>()
  var results: Driver<[GameSearchSuggestion]> { return resultsRelay.asDriver(onErrorJustReturn: []) }
  
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
      .bind(to: resultsRelay)
      .disposed(by: bag)
  }
}
