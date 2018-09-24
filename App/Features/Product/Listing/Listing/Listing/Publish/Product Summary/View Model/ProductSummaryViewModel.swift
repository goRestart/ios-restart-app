import Domain
import RxSwift
import RxCocoa

struct ProductSummaryViewModel: ProductSummaryViewModelType, ProductSummaryViewModelInput, ProductSummaryViewModelOutput {
  
  var input: ProductSummaryViewModelInput { return self }
  var output: ProductSummaryViewModelOutput { return self }
  
  private let getProductDraft: ProductDraftUseCase
  private let productDraftViewMapper: ProductDraftViewMapper
  private let uploadProduct: UploadProductUseCase
  private let coordinator: ProductSummaryCoordinator
  private let bag = DisposeBag()
  
  init(getProductDraft: ProductDraftUseCase,
       productDraftViewMapper: ProductDraftViewMapper,
       uploadProduct: UploadProductUseCase,
       coordinator: ProductSummaryCoordinator)
  {
    self.getProductDraft = getProductDraft
    self.productDraftViewMapper = productDraftViewMapper
    self.uploadProduct = uploadProduct
    self.coordinator = coordinator
  }
  
  // MARK: - Output
  
  private let stateRelay = PublishRelay<ProductSummaryState>()
  var state: Driver<ProductSummaryState> {
    return stateRelay.asDriver(onErrorJustReturn: .idle)
  }

  private let productDraftRelay = PublishRelay<ProductDraftUIModel?>()
  var productDraft: Driver<ProductDraftUIModel?> {
    return productDraftRelay.asDriver(onErrorJustReturn: nil)
  }
  
  // MARK: - Input
  
  func viewDidLoad() {
    let productDraft = getProductDraft.get()
    guard let productDraftUIModel = try? productDraftViewMapper.map(productDraft) else { return }
    productDraftRelay.accept(productDraftUIModel)
  }
  
  func publishButtonPressed() {
    let productDraft = getProductDraft.get()
    
    stateRelay.accept(.publishing)
    
    uploadProduct.execute(with: productDraft)
      .subscribe(onCompleted: {
        self.coordinator.close()
      }) { error in
        self.stateRelay.accept(.idle)
        // TODO: Handle error
    }.disposed(by: bag)
  }
}
