import UI
import IGListKit
import RxSwift
import RxCocoa

final class ProductExtrasListAdapter: NSObject, ListAdapterDataSource {
  
  private var productExtras = [ProductExtraUIModel]()
  
  private let state: PublishRelay<ProductExtraEvent>
  
  init(state: PublishRelay<ProductExtraEvent>) {
    self.state = state
  }
  
  func set(_ productExtras: [ProductExtraUIModel]) {
    self.productExtras = productExtras
  }
  
  func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    return productExtras
  }
  
  func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
    guard let object = object as? ProductExtraUIModel else { fatalError() }
    let sectionController = ProductExtraSectionController(
      productExtra: object,
      state: state
    )
    sectionController.inset = UIEdgeInsets(top: Margin.small, left: Margin.medium, bottom: 0, right: Margin.medium)
    return sectionController
  }
  
  func emptyView(for listAdapter: ListAdapter) -> UIView? {
    guard productExtras.isEmpty else { return nil }
    let loadingActivity = UIActivityIndicatorView(style: .gray)
    loadingActivity.hidesWhenStopped = true
    loadingActivity.startAnimating()
    return loadingActivity
  }
}
