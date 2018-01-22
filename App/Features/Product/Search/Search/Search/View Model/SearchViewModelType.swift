import RxSwift
import Domain

protocol SearchViewModelOutput {
  var results: Variable<[GameSearchSuggestion]> { get }
  func bind(to query: Observable<String>)
}

protocol SearchViewModelType {
  var output: SearchViewModelOutput { get }
}
