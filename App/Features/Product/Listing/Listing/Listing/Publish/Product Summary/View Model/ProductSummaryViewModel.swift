import Domain
import RxSwift
import RxCocoa

struct ProductSummaryViewModel: ProductSummaryViewModelType, ProductSummaryViewModelInput, ProductSummaryViewModelOutput {
  
  var input: ProductSummaryViewModelInput { return self }
  var output: ProductSummaryViewModelOutput { return self }
  
  private let getProductDraft: ProductDraftUseCase
  private let productDraftViewMapper: ProductDraftViewMapper
  private let uploadProduct: UploadProductUseCase
  private let bag = DisposeBag()
  
  init(getProductDraft: ProductDraftUseCase,
       productDraftViewMapper: ProductDraftViewMapper,
       uploadProduct: UploadProductUseCase)
  {
    self.getProductDraft = getProductDraft
    self.productDraftViewMapper = productDraftViewMapper
    self.uploadProduct = uploadProduct
  }
  
  // MARK: - Output
  
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
    uploadProduct.execute(with: productDraft)
      .subscribe(onCompleted: {
        print("Product uploaded correctly")
      }) { error in
        // TODO: Handle error
    }.disposed(by: bag)
  }
}
