import Domain
import RxSwift
import RxCocoa

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

  var nextStepEnabled: Driver<Bool> {
    return price.map { $0.isFloatable }
      .asDriver(onErrorJustReturn: false)
  }
  
  var price: Driver<String> {
    return priceRelay.asDriver(onErrorJustReturn: "")
  }

  // MARK: - Input

  private let priceRelay = BehaviorRelay<String>(value: "")
  
  func viewWillAppear() {
    guard let productPrice = productDraft.get().price else { return }
    priceRelay.accept(
      productPrice.amount.toString()
    )
  }
  
  func onChange(price: String) {
    priceRelay.accept(price)
  }
  
  func onNextStepPressed() {
    productDraft.save(
      price: priceRelay.value.toDouble()
    )
    productExtrasNavigator.navigate()
  }
}
