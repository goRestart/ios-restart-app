import RxSwift
import Domain

struct ProductDescriptionViewModel: ProductDescriptionViewModelType, ProductDescriptionViewModelInput, ProductDescriptionViewModelOutput {

  var input: ProductDescriptionViewModelInput { return self }
  var output: ProductDescriptionViewModelOutput { return self }

  private let productDraft: ProductDraftUseCase
  private let productPriceNavigator: ProductPriceNavigator
  
  init(productDraft: ProductDraftUseCase,
       productPriceNavigator: ProductPriceNavigator)
  {
    self.productDraft = productDraft
    self.productPriceNavigator = productPriceNavigator
  }
  
  // MARK: - Output

  var description = BehaviorSubject<String>(value: "")
  var nextStepEnabled: Observable<Bool> {
    return description.map { !$0.trimmed.isEmpty }
  }
  
  // MARK: - Input

  func viewWillAppear() {
    guard let savedDescription = productDraft.get().description else { return }
    description.onNext(savedDescription)
  }
  
  func onNextStepPressed() {
    productDraft.save(
      description: try! description.value()
    )
    productPriceNavigator.navigate()
  }
}
