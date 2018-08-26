import RxSwift
import Domain

struct ProductDescriptionViewModel: ProductDescriptionViewModelType, ProductDescriptionViewModelInput, ProductDescriptionViewModelOutput {

  var input: ProductDescriptionViewModelInput { return self }
  var output: ProductDescriptionViewModelOutput { return self }

  private let productPriceNavigator: ProductPriceNavigator
  
  init(productPriceNavigator: ProductPriceNavigator) {
    self.productPriceNavigator = productPriceNavigator
  }
  
  // MARK: - Output

  var description = BehaviorSubject<String>(value: "")
  var nextStepEnabled: Observable<Bool> {
    return description.map { !$0.trimmed.isEmpty }
  }

  // MARK: - Input

  func onNextStepPressed() {
    productPriceNavigator.navigate()
  }
}
