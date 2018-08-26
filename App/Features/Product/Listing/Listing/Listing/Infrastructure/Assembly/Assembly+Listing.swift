import Core
import UI

public protocol ListingProvider {
  func makeNewListingProcess() -> UIViewController
}

extension Assembly: ListingProvider {
  public func makeNewListingProcess() -> UIViewController {
    let navigationController = NavigationController(
      rootViewController: productSelector
    )
    return navigationController
  }
}
