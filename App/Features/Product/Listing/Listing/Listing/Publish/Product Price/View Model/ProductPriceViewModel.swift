import RxSwift
import Domain

struct ProductPriceViewModel: ProductPriceViewModelType, ProductPriceViewModelInput, ProductPriceViewModelOutput {

  var input: ProductPriceViewModelInput { return self }
  var output: ProductPriceViewModelOutput { return self }

  private let productExtrasNavigator: ProductExtrasNavigator
  
  init(productExtrasNavigator: ProductExtrasNavigator) {
    self.productExtrasNavigator = productExtrasNavigator
  }
  
  // MARK: - Output

  var price = BehaviorSubject<String>(value: "")
  var nextStepEnabled: Observable<Bool> {
    return price
      .map { $0.trimmed }
      .map { !$0.isEmpty && $0.isFloatable }
  }

  // MARK: - Input

  func onNextStepPressed() {
    productExtrasNavigator.navigate()
  }
}
