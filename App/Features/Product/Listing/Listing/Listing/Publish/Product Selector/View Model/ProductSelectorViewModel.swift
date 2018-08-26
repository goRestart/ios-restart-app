import Domain
import RxSwift

struct ProductSelectorViewModel: ProductSelectorViewModelType, ProductSelectorViewModelInput {

  var input: ProductSelectorViewModelInput { return self }

  private let productDescriptionNavigator: ProductDescriptionNavigator
  
  init(productDescriptionNavigator: ProductDescriptionNavigator) {
    self.productDescriptionNavigator = productDescriptionNavigator
  }
  
  func onGameSelected(with id: Identifier<Game>) {
    print("Game with id \(id) selected")
    productDescriptionNavigator.navigate()
  }
}
