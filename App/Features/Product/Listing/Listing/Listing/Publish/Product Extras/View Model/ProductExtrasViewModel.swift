import Domain
import RxSwift

final class ProductExtrasViewModel: ProductExtrasViewModelType, ProductExtrasViewModelInput, ProductExtrasViewModelOutput {
  var input: ProductExtrasViewModelInput { return self }
  var output: ProductExtrasViewModelOutput { return self }
  
  private var productExtraSelections = [Identifier<Product.Extra>: Bool]()
  private var selectedProductExtras: [Identifier<Product.Extra>] {
    return productExtraSelections.filter { $0.value }.map { $0.key }
  }
  
  private let productDraft: ProductDraftUseCase
  private let getProductExtras: GetProductExtrasUseCase
  private let productSummaryNavigator: ProductSummaryNavigator
  private let bag = DisposeBag()
  
  init(productDraft: ProductDraftUseCase,
       getProductExtras: GetProductExtrasUseCase,
       productSummaryNavigator: ProductSummaryNavigator)
  {
    self.productDraft = productDraft
    self.getProductExtras = getProductExtras
    self.productSummaryNavigator = productSummaryNavigator
  }
  
  // MARK: Output

  private let productExtrasPublisher = PublishSubject<[ProductExtraUIModel]>()
  var productExtras: Observable<[ProductExtraUIModel]> { return productExtrasPublisher }

  // MARK: - Input
  
  func viewDidLoad() {
    restoreSelectedProductExtras()
    
    getProductExtras.execute()
      .map(toUI)
      .asObservable()
      .bind(to: productExtrasPublisher)
      .disposed(by: bag)
  }
  
  private func restoreSelectedProductExtras() {
    productDraft.get().productExtras.forEach { [weak self] element in
      self?.productExtraSelections[element] = true
    }
  }
  
  private func toUI(_ productExtras: [Product.Extra]) -> [ProductExtraUIModel] {
    return productExtras.map { [weak self] element in
      let productExtra = ProductExtraUIModel(productExtra: element)
      productExtra.isSelected = self?.productExtraSelections[productExtra.identifier] ?? false
      return productExtra
    }
  }
  
  func didSelectProductExtra(with id: Identifier<Product.Extra>) {
    productExtraSelections[id] = true
  }
  
  func didUnSelectProductExtra(with id: Identifier<Product.Extra>) {
    productExtraSelections[id] = false
  }
  
  func didTapNextButton() {
    productDraft.save(productExtras: selectedProductExtras)
    productSummaryNavigator.navigate()
  }
}
