import UIKit

final class CategoriesFeedCell: UICollectionViewCell {
    
    private let categoryView = CategoriesHeaderCollectionView()
    static let viewHeight: CGFloat = CategoriesHeaderCollectionView.viewHeight

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviewForAutoLayout(categoryView)
        categoryView.layout(with: self).fill()
    }
    
    func configure(with feedPresenter: CategoriesBubblePresentable) {
        categoryView.configure(with: feedPresenter.categories,
                               categoryHighlighted: feedPresenter.categoryHighlighted,
                               isMostSearchedItemsEnabled: feedPresenter.isMostSearchedItemsEnabled)
        categoryView.delegateCategoryHeader = feedPresenter
    }
}

