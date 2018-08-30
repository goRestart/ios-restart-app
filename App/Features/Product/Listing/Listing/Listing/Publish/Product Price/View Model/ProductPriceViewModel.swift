import RxSwift
import Domain

struct ProductPriceViewModel: ProductPriceViewModelType, ProductPriceViewModelInput, ProductPriceViewModelOutput {

  var input: ProductPriceViewModelInput { return self }
  var output: ProductPriceViewModelOutput { return self }

  private let productDraft: ProductDraftUseCase
  private let productExtrasNavigator: ProductExtrasNavigator
  
  init(productDraft: ProductDraftUseCase,
       productExtrasNavigator: ProductExtrasNavigator)
  {
    self.productDraft = productDraft
    self.productExtrasNavigator = productExtrasNavigator
  }
  
  // MARK: - Output

  var nextStepEnabled: Observable<Bool> {
    return price.map { $0.isFloatable }
  }

  // MARK: - Input

  var price = BehaviorSubject<String>(value: "")
  
  func viewWillAppear() {
    guard let productPrice = productDraft.get().price else { return }
    price.onNext(
      productPrice.amount.toString()
    )
  }
  
  func onNextStepPressed() {
    productDraft.save(
      price: try! price.value().toDouble()
    )
    productExtrasNavigator.navigate()
  }
}
