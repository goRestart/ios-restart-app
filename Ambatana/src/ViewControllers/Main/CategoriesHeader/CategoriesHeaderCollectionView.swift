import RxSwift
import LGCoreKit


struct CategoryHeaderInfo {
    let filterCategoryItem: FilterCategoryItem
    let position: Int
    let name: String
}

protocol CategoriesHeaderCollectionViewDelegate: class {
    func categoryHeaderDidSelect(categoryHeaderInfo: CategoryHeaderInfo)
}

final class CategoriesHeaderCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var categoryElements: [FilterCategoryItem] = []
    private var categoryHighlighted: FilterCategoryItem?
    
    weak var delegateCategoryHeader: CategoriesHeaderCollectionViewDelegate?
    
    var categorySelected = Variable<CategoryHeaderInfo?>(nil)
    
    static let viewHeight: CGFloat = CategoryHeaderCell.cellSize().height
    
    init() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CategoryHeaderCell.cellSize()
        super.init(frame: .zero, collectionViewLayout: layout)
        setup()
        setAccessibilityIds()
    }
    
    func configure(with categories: [FilterCategoryItem], categoryHighlighted: FilterCategoryItem) {
        self.categoryElements = categories
        self.categoryHighlighted = categoryHighlighted
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UICollectionViewDelegate & DataSource methods
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CategoryHeaderCell.cellSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryElements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryHeaderCell.reuseIdentifier,
                                                            for: indexPath) as? CategoryHeaderCell else { return UICollectionViewCell() }
        let categoryHeaderElement = categoryElements[indexPath.row]
        cell.categoryTitle.addKern(value: -0.30)
        cell.categoryIcon.image = categoryHeaderElement.imageInFeed
        cell.categoryTitle.text = categoryHeaderElement.name.localizedUppercase

        if let categoryHighlighted = self.categoryHighlighted,
            categoryHeaderElement == categoryHighlighted {
            cell.addNewTagToCategory()
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        let categoryHeaderElement = categoryElements[indexPath.row]
        let headerInfo = CategoryHeaderInfo(filterCategoryItem: categoryHeaderElement,
                                            position: indexPath.row + 1,
                                            name: categoryHeaderElement.name)
        
        categorySelected.value = headerInfo
        delegateCategoryHeader?.categoryHeaderDidSelect(categoryHeaderInfo: headerInfo)
    }

    
    // MARK: - Private methods
    
    private func setup() {
        dataSource = self
        delegate = self
        scrollsToTop = false
        showsHorizontalScrollIndicator = false
        
        backgroundColor = .clear
        
        // CollectionView cells
        register(CategoryHeaderCell.self, forCellWithReuseIdentifier: CategoryHeaderCell.reuseIdentifier)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }
    }
    
    private func setAccessibilityIds() {
        set(accessibilityId: .filterTagsCollectionView)
    }
}
