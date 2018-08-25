import Domain
import RxSwift

final class ProductExtrasViewModel: ProductExtrasViewModelType, ProductExtrasViewModelInput, ProductExtrasViewModelOutput {
  var input: ProductExtrasViewModelInput { return self }
  var output: ProductExtrasViewModelOutput { return self }
  
  private var productExtraSelections = [Identifier<Product.Extra>: Bool]()
  private var selectedProductExtras: [Identifier<Product.Extra>] {
    return productExtraSelections.filter { $0.value }.map { $0.key }
  }
  
  private let getProductExtras: GetProductExtrasUseCase
  private let bag = DisposeBag()
  
  init(getProductExtras: GetProductExtrasUseCase) {
    self.getProductExtras = getProductExtras
  }
  
  // MARK: Output
  
  var productExtras = PublishSubject<[ProductExtraUIModel]>()
  var state = PublishSubject<ProductExtrasState>()
  
  // MARK: - Input
  
  func viewDidLoad() {
    state.onNext(.loading)
    
    getProductExtras.execute()
      .map(toUI)
      .subscribe(onSuccess: { [weak self] productExtras in
        self?.state.onNext(.idle)
        self?.productExtras.onNext(productExtras)
      }) { (error) in
        // TODO: Handle error
    }.disposed(by: bag)
  }
  
  private func toUI(_ productExtras: [Product.Extra]) -> [ProductExtraUIModel] {
    return productExtras.map { ProductExtraUIModel(productExtra: $0) }
  }
  
  func didSelectProductExtra(with id: Identifier<Product.Extra>) {
    productExtraSelections[id] = true
  }
  
  func didUnSelectProductExtra(with id: Identifier<Product.Extra>) {
    productExtraSelections[id] = false
  }
  
  func didTapNextButton() {
    print("Next page with items = \(selectedProductExtras)")
  }
}
