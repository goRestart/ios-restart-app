import Domain
import RxSwift
import RxCocoa

protocol ProductExtrasViewModelInput {
  func viewDidLoad()
  func onSelectProductExtra(with id: Identifier<Product.Extra>)
  func onUnSelectProductExtra(with id: Identifier<Product.Extra>)
  func nextButtonPressed()
}

protocol ProductExtrasViewModelOutput {
  var productExtras: Driver<[ProductExtraUIModel]> { get }
}

protocol ProductExtrasViewModelType {
  var input: ProductExtrasViewModelInput { get }
  var output: ProductExtrasViewModelOutput { get }
}
