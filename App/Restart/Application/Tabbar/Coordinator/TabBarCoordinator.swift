import UI
import Listing

final class TabBarCoordinator {
  
  weak var tabBarController: TabBarController?
  
  private let listingProvider: ListingProvider
  
  init(listingProvider: ListingProvider) {
    self.listingProvider = listingProvider
  }
  
  func openPublishNewProduct() {
    tabBarController?.present(listingProvider.makeNewListingProcess(), animated: true)
  }
}
