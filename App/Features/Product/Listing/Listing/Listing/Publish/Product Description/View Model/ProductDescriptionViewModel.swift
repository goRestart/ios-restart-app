import Domain
import RxSwift
import RxCocoa

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

  var nextStepEnabled: Driver<Bool> {
    return descriptionSubject.map { !$0.trimmed.isEmpty }
      .asDriver(onErrorJustReturn: false)
  }
  
  var description: Driver<String> {
    return descriptionSubject.asDriver(onErrorJustReturn: "")
  }
  
  // MARK: - Input

  private let descriptionSubject = BehaviorSubject<String>(value: "")

  func viewWillAppear() {
    guard let savedDescription = productDraft.get().description else { return }
    descriptionSubject.onNext(savedDescription)
  }

  func onChange(description: String) {
    descriptionSubject.onNext(description)
  }
  
  func onNextStepPressed() {
    productDraft.save(
      description: try! descriptionSubject.value()
    )
    productPriceNavigator.navigate()
  }
}
