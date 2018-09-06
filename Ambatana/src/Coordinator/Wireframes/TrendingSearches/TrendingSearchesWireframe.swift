import LGCoreKit
import LGComponents

protocol TrendingSearchesNavigator: class {
    func cancelSearch()
}

final class TrendingSearchesWireframe: TrendingSearchesNavigator {
    private let root: UIViewController
    
    init(root: UIViewController) { self.root = root }
    
    func cancelSearch() { root.dismiss(animated: true, completion: nil) }
}
