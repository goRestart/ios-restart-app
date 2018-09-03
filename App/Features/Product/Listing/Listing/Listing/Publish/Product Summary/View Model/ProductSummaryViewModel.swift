import RxSwift
import Domain

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
  
  private let productDraftPublisher = PublishSubject<ProductDraftUIModel>()
  var productDraft: Observable<ProductDraftUIModel> { return productDraftPublisher }
  
  // MARK: - Input
  
  func viewDidLoad() {
    let storedProductDraft = getProductDraft.get()
    guard let productDraftUIModel = try? productDraftViewMapper.map(storedProductDraft) else { return }
    productDraftPublisher.onNext(productDraftUIModel)
  }
  
  func publishButtonPressed() {
    
  }
}
