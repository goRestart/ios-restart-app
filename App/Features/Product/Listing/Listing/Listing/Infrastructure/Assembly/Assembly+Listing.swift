import Core

public protocol ListingProvider {
  func makeNewListingProcess() -> UIViewController
}

extension Assembly: ListingProvider {
  public func makeNewListingProcess() -> UIViewController {
    let navigationController = UINavigationController(
      rootViewController: productSelector
    )
    navigationController.navigationBar.prefersLargeTitles = true
    return navigationController
  }
}
