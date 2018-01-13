import RxSwift
import Domain

protocol SearchViewModelInput {
  func didSelect(game: Game)
}

protocol SearchViewModelOutput {
  var query: Variable<String> { get }
}

protocol SearchViewModelType {
  var input: SearchViewModelInput { get }
  var output: SearchViewModelOutput { get }
}
