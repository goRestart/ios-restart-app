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
    return priceSubject.asDriver(onErrorJustReturn: "")
  }

  // MARK: - Input

  private let priceSubject = BehaviorSubject<String>(value: "")
  
  func viewWillAppear() {
    guard let productPrice = productDraft.get().price else { return }
    priceSubject.onNext(
      productPrice.amount.toString()
    )
  }
  
  func onChange(price: String) {
    priceSubject.onNext(price)
  }
  
  func onNextStepPressed() {
    productDraft.save(
      price: try! priceSubject.value().toDouble()
    )
    productExtrasNavigator.navigate()
  }
}
