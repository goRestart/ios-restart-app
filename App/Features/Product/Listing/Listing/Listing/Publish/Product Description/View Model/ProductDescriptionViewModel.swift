import Domain
import RxSwift
import RxCocoa

struct ProductDescriptionViewModel: ProductDescriptionViewModelType, ProductDescriptionViewModelInput, ProductDescriptionViewModelOutput {
 
  var input: ProductDescriptionViewModelInput { return self }
  var output: ProductDescriptionViewModelOutput { return self }

  private let productDraft: ProductDraftUseCase
  private let productPriceNavigator: ProductPriceNavigable
  
  init(productDraft: ProductDraftUseCase,
       productPriceNavigator: ProductPriceNavigable)
  {
    self.productDraft = productDraft
    self.productPriceNavigator = productPriceNavigator
  }
  
  // MARK: - Output

  var nextStepEnabled: Driver<Bool> {
    return descriptionRelay.map { !$0.trimmed.isEmpty }
      .asDriver(onErrorJustReturn: false)
  }
  
  var description: Driver<String> {
    return descriptionRelay.asDriver(onErrorJustReturn: "")
  }
  
  // MARK: - Input

  private let descriptionRelay = BehaviorRelay<String>(value: "")

  func viewWillAppear() {
    guard let savedDescription = productDraft.get().description else { return }
    descriptionRelay.accept(savedDescription)
  }

  func onChange(description: String) {
    descriptionRelay.accept(description)
  }
  
  func onNextStepPressed() {
    productDraft.save(
      description: descriptionRelay.value.trimmed
    )
    productPriceNavigator.navigate()
  }
}
