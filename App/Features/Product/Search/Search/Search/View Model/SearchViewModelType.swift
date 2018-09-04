import Domain
import RxSwift
import RxCocoa

protocol SearchViewModelOutput {
  var results: Driver<[GameSearchSuggestion]> { get }
  func bind(to query: Observable<String>)
}

protocol SearchViewModelType {
  var output: SearchViewModelOutput { get }
}
