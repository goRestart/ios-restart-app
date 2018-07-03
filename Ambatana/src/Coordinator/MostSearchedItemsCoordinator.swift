import LGCoreKit
import LGComponents

protocol MostSearchedItemsCoordinatorDelegate: class {
    func openSell(source: PostingSource, mostSearchedItem: LocalMostSearchedItem)
    func openSearchFor(listingTitle: String)
}

class MostSearchedItemsCoordinator: Coordinator {
    
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    var bubbleNotificationManager: BubbleNotificationManager
    var sessionManager: SessionManager
    fileprivate let locationManager: LocationManager

    fileprivate let featureFlags: FeatureFlaggeable
    weak var delegate: MostSearchedItemsCoordinatorDelegate?
    
    convenience init(source: PostingSource,
                     enableSearch: Bool) {
        self.init(source: source,
                  enableSearch: enableSearch,
                  featureFlags: FeatureFlags.sharedInstance,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager,
                  locationManager: Core.locationManager)
    }
    
    init(source: PostingSource,
         enableSearch: Bool,
         featureFlags: FeatureFlags,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager,
         locationManager: LocationManager) {
        self.featureFlags = featureFlags
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        self.locationManager = locationManager
        
        let mostSearchedItemsVM = MostSearchedItemsListViewModel(isSearchEnabled: enableSearch,
                                                                 locationManager: locationManager,
                                                                 postingSource: source)
        let mostSearchedItemsVC = MostSearchedItemsListViewController(viewModel: mostSearchedItemsVM)
        let navigationController = UINavigationController(rootViewController: mostSearchedItemsVC)
        self.viewController = navigationController
        mostSearchedItemsVM.navigator = self
    }
    
    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }
    
    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}

extension MostSearchedItemsCoordinator: MostSearchedItemsNavigator {
    func cancel() {
        dismissViewController(animated: true, completion: nil)
    }
    
    func openSell(mostSearchedItem: LocalMostSearchedItem, source: PostingSource) {
        closeCoordinator(animated: true) { [weak self] in
            self?.delegate?.openSell(source: source, mostSearchedItem: mostSearchedItem)
        }
    }
    
    func openSearchFor(listingTitle: String) {
        closeCoordinator(animated: true) { [weak self] in
            self?.delegate?.openSearchFor(listingTitle: listingTitle)
        }
    }
}
