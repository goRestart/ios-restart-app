import Domain
import RxSwift

struct ProductSelectorViewModel: ProductSelectorViewModelType, ProductSelectorViewModelInput {

  var input: ProductSelectorViewModelInput { return self }

  private let productDraft: ProductDraftUseCase
  private let productDescriptionNavigator: ProductDescriptionNavigator
  
  init(productDraft: ProductDraftUseCase,
       productDescriptionNavigator: ProductDescriptionNavigator)
  {
    self.productDraft = productDraft
    self.productDescriptionNavigator = productDescriptionNavigator
  }
  
  func onGameSelected(with title: String, _ identifier: Identifier<Game>) {
    productDraft.save(with: title, productId: Identifier(identifier))
    productDescriptionNavigator.navigate()
  }
}
