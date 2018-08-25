import Domain
import RxSwift

protocol ProductExtrasViewModelInput {
  func viewDidLoad()
  func didSelectProductExtra(with id: Identifier<Product.Extra>)
  func didUnSelectProductExtra(with id: Identifier<Product.Extra>)
  func didTapNextButton()
}

protocol ProductExtrasViewModelOutput {
  var productExtras: PublishSubject<[ProductExtraUIModel]> { get }
}

protocol ProductExtrasViewModelType {
  var input: ProductExtrasViewModelInput { get }
  var output: ProductExtrasViewModelOutput { get }
}
