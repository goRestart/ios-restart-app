import UIKit
import LGComponents

struct FeedCellDrawer {
    
    static func configure(withHeaderView headerView: UICollectionReusableView,
                          for feedPresenter: FeedPresenter) {
        switch headerView {
        case let headerView as PushPermissionsHeaderCell:
            if let feedPresenter = feedPresenter as? PushPermissionsPresenter {
                headerView.configure(with: feedPresenter)
            }
        case is EmptyHeaderReusableCell:
            break
        case let headerView as CategoriesFeedHeaderCell:
            if let feedPresenter = feedPresenter as? CategoryPresenter {
                headerView.configure(with: feedPresenter)
            }
        case let headerView as FilterTagFeedHeaderCell:
            if let feedPresenter = feedPresenter as? FilterTagFeedPresenter {
                headerView.configure(with: feedPresenter)
            }
        default:
            logConfigurationError(for: headerView)
        }
    }
    
    static func configure(withCell cell: UICollectionReusableView,
                          for feedPresenter: FeedPresenter) {
        // FIXME: Implement this when item cells are ready
    }
    
    private static func logConfigurationError(for view: UIView) {
        logMessage(.debug,
                   type: .uikit,
                   message: UIViewConfigError.viewNotConfigured(view: view).description)
    }
}
