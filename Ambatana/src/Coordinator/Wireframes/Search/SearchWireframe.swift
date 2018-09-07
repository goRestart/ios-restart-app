import LGCoreKit
import LGComponents

protocol SearchResultsNavigator: class {
    func cancelSearch()
}

final class SearchWireframe: SearchResultsNavigator {
    private let root: UIViewController
    
    init(root: UIViewController) { self.root = root }
    
    func cancelSearch() { root.dismiss(animated: true, completion: nil) }
}
