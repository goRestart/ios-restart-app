import LGCoreKit
import LGComponents

protocol ExpandableCategorySelectionDelegate: class {
    func didPressCloseButton()
    func tapOutside()
    func didPressCategory(_ postCategory: PostCategory)
}

final class ExpandableCategorySelectionViewModel: BaseViewModel {
    
    weak var delegate: ExpandableCategorySelectionDelegate?
    
    var postCategories: [PostCategory] = []
    var newBadgePosition: Int? {
        return postCategories.enumerated().first { $1 == newBadgePostCategory }?.offset
    }
    
    private let featureFlags: FeatureFlaggeable
    
    // MARK: - View lifecycle
    
    init(featureFlags: FeatureFlaggeable) {
        self.featureFlags = featureFlags
        super.init()
        self.postCategories = buildSortedPostCategories()
    }
    
    // MARK: - UI Actions
    
    func closeButtonAction() {
        delegate?.didPressCloseButton()
    }

    func tapOutside() {
        delegate?.tapOutside()
    }
    
    func pressCategoryAction(index: Int) {
        guard let postListingCategory = postCategories[safeAt: index] else { return }
        delegate?.didPressCategory(postListingCategory)
    }
}

extension ExpandableCategorySelectionViewModel {
    
    private func buildSortedPostCategories() -> [PostCategory] {
        let postCategories = PostCategory.buildPostCategories(featureFlags: featureFlags)
        return postCategories.sorted(by: {
            $0.sortWeight(featureFlags: featureFlags) < $1.sortWeight(featureFlags: featureFlags)
        })
    }
    
    private var newBadgePostCategory: PostCategory {
        return featureFlags.jobsAndServicesEnabled.isActive ? .jobs : .services
    }
}
