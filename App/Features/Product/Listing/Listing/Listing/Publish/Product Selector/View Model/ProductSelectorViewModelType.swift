import Domain
import RxSwift

protocol ProductSelectorViewModelInput {
  func onGameSelected(with title: String, _ identifier: Identifier<Game>)
}

protocol ProductSelectorViewModelType {
  var input: ProductSelectorViewModelInput { get }
}
