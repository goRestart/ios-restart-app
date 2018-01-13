import RxSwift
import Domain

struct SearchViewModel: SearchViewModelType, SearchViewModelOutput {
 
  var output: SearchViewModelOutput { return self }
 
  var results = Variable<[Game]>([])
  
  private let bag = DisposeBag()
  private let searchGames: SearchGamesUseCase
  
  init(searchGames: SearchGamesUseCase) {
    self.searchGames = searchGames
  }
 
  // MARK: - Output
  
  func bind(to query: Observable<String>) {
    query.map {
      self.searchGames.execute(with: $0)
    }.flatMap { $0.asObservable() }
      .catchErrorJustReturn([])
      .bind(to: results)
      .disposed(by: bag)
    }
}
