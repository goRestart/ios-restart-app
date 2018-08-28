import IGListKit

final class CategoryBubbleSectionController: ListSectionController {
    
    private let categoryViewModel: CategoryViewModel
    
    weak var delegate: CategoriesHeaderCollectionViewDelegate? {
        didSet {
            categoryViewModel.delegate = delegate
        }
    }
    
    init(featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.categoryViewModel = CategoryViewModel(featureFlags: featureFlags)
        super.init()
        inset = SectionControllerLayout.categoryBubbleSectionInset
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let height = CategoriesFeedCell.viewHeight
        let width = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: CategoriesFeedCell.self,
                                                                for: self,
                                                                at: index) as? CategoriesFeedCell
            
            else { fatalError() }
        cell.configure(with: categoryViewModel)
        return cell
    }
}

