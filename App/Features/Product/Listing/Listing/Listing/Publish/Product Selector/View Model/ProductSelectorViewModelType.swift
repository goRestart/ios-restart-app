import Domain
import RxSwift

protocol ProductSelectorViewModelInput {
  func onGameSelected(with id: Identifier<Game>)
}

protocol ProductSelectorViewModelType {
  var input: ProductSelectorViewModelInput { get }
}
