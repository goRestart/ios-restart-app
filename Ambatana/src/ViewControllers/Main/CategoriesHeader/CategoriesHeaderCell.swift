import UIKit
import LGCoreKit
import LGComponents

class CategoryHeaderCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CategoryHeaderCell"
    
    var categoryIcon: UIImageView = UIImageView()
    var categoryTitle: UILabel = UILabel()
    var categoryNewLabel: UILabel = UILabel()
    var categoryNewContainter: UIView = UIView()
    
    
    // MARK: - Static methods
    
    static func cellSize() -> CGSize {
        return CGSize(width: 80, height: 120)
    }

    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        categoryIcon.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        categoryIcon.contentMode = .scaleAspectFit
        contentView.addSubview(categoryIcon)
        contentView.addSubview(categoryTitle)
        contentView.addSubview(categoryNewContainter)
        categoryNewContainter.addSubview(categoryNewLabel)
        self.setupUI()
        self.resetUI()
        self.setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        categoryNewContainter.setRoundedCorners()
    }
    
    
    // MARK: - Public Methods
    
    func addNewTagToCategory() {
        categoryNewContainter.isHidden = false
        categoryNewLabel.text = R.Strings.commonNew
        layoutIfNeeded()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        
        backgroundColor = .clear
        categoryNewContainter.backgroundColor = UIColor.white
        categoryNewLabel.backgroundColor = .clear
        
        categoryTitle.translatesAutoresizingMaskIntoConstraints = false
        categoryNewLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryIcon.translatesAutoresizingMaskIntoConstraints = false
        categoryNewContainter.translatesAutoresizingMaskIntoConstraints = false
        
        let subviews = [categoryTitle, categoryNewLabel, categoryIcon, categoryNewContainter]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        
        categoryTitle.font = UIFont.boldSystemFont(ofSize: 9)
        categoryNewLabel.font = UIFont.boldSystemFont(ofSize: 9)
        
        categoryTitle.textColor = UIColor.grayDark
        categoryNewLabel.textColor = UIColor.lgBlack
        
        categoryIcon.layout().height(60).width(60)
        categoryIcon.layout(with: contentView).top(by: 20).centerX()
        categoryTitle.layout(with: contentView).leading(by: 2).trailing(by: -2)
        categoryTitle.layout(with: categoryIcon).top(to: .bottom, by: 10)
        categoryTitle.textAlignment = .center
        categoryTitle.numberOfLines = 2
        categoryNewContainter.layout(with: contentView).top(by: 10).centerX()
        
        categoryNewLabel.layout(with: categoryNewContainter).top(by: 3).left(by: 10).right(by: -10).bottom(by: -3)
        categoryNewLabel.textAlignment = .center
        
        categoryNewContainter.applyDefaultShadow()
    }
    
    private func resetUI() {
        categoryTitle.text = ""
        categoryNewLabel.text = ""
        categoryIcon.image = nil
        categoryNewContainter.isHidden = true
    }
    
    private func setAccessibilityIds() {
        categoryIcon.set(accessibilityId: .categoryHeaderCellCategoryIcon)
        categoryTitle.set(accessibilityId: .categoryHeaderCellCategoryTitle)
    }
}
