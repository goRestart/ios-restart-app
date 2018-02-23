import Domain
import RxSwift

struct ProductSelectorViewModel: ProductSelectorViewModelType, ProductSelectorViewModelInput {

  var input: ProductSelectorViewModelInput { return self }

  func onGameSelected(with id: Identifier<Game>) {
    print("Game with id \(id) selected")
  }
}
