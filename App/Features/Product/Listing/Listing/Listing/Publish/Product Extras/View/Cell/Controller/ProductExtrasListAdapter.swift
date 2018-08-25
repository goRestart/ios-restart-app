import UI
import IGListKit
import RxSwift

final class ProductExtrasListAdapter: NSObject, ListAdapterDataSource {
  
  var productExtras = [ProductExtraUIModel]()
  
  private let state: PublishSubject<ProductExtraEvent>
  
  init(state: PublishSubject<ProductExtraEvent>) {
    self.state = state
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
    let loadingActivity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    loadingActivity.hidesWhenStopped = true
    loadingActivity.startAnimating()
    return loadingActivity
  }
}
