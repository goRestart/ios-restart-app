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

  var nextStepEnabled: Observable<Bool> {
    return price.map { $0.isFloatable }
  }

  // MARK: - Input

  var price = BehaviorSubject<String>(value: "")
  
  func onNextStepPressed() {
    productExtrasNavigator.navigate()
  }
}
