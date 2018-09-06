import Domain
import RxSwift
import RxCocoa

struct ProductSummaryViewModel: ProductSummaryViewModelType, ProductSummaryViewModelInput, ProductSummaryViewModelOutput {
  
  var input: ProductSummaryViewModelInput { return self }
  var output: ProductSummaryViewModelOutput { return self }
  
  private let getProductDraft: ProductDraftUseCase
  private let productDraftViewMapper: ProductDraftViewMapper
  
  init(getProductDraft: ProductDraftUseCase,
       productDraftViewMapper: ProductDraftViewMapper)
  {
    self.getProductDraft = getProductDraft
    self.productDraftViewMapper = productDraftViewMapper
  }
  
  // MARK: - Output
  
  private let productDraftRelay = PublishRelay<ProductDraftUIModel?>()
  var productDraft: Driver<ProductDraftUIModel?> {
    return productDraftRelay.asDriver(onErrorJustReturn: nil)
  }
  
  // MARK: - Input
  
  func viewDidLoad() {
    let storedProductDraft = getProductDraft.get()
    guard let productDraftUIModel = try? productDraftViewMapper.map(storedProductDraft) else { return }
    productDraftRelay.accept(productDraftUIModel)
  }
  
  func publishButtonPressed() {
    
  }
}
