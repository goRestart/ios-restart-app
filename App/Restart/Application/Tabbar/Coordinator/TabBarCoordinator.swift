import UI
import Listing
import SignUp
import RxSwift
import FirebaseAuth

final class TabBarCoordinator {
  
  weak var tabBarController: TabBarController?
  
  private let listingProvider: ListingProvider
  private let notLoggedProvider: NotLoggedProvider
  private var notLoggedViewController: UIViewController?
  private let bag = DisposeBag()
  
  init(listingProvider: ListingProvider,
       notLoggedProvider: NotLoggedProvider)
  {
    self.listingProvider = listingProvider
    self.notLoggedProvider = notLoggedProvider
  }
  
  func openPublishNewProduct() {
    Auth.auth().rx.authenticated.subscribe(onNext: { [weak self] authenthicated in
 
      guard authenthicated else {
        self?.openNotLogged()
        return
      }
      
      self?.openNewListing()
      
    }).disposed(by: bag)
  }
  
  private func openNotLogged() {
    notLoggedViewController = notLoggedProvider.makeNotLogged()
    tabBarController?.present(notLoggedViewController!, animated: true)
  }
  
  private func openNewListing() {
    if let notLoggedViewController = notLoggedViewController {
      notLoggedViewController.dismiss(animated: false)
    }
    
    tabBarController?.present(
      listingProvider.makeNewListingProcess(), animated: true
    )
  }
}
