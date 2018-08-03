import UIKit

final class FilterAttributeGridCell: UICollectionViewCell, ReusableCell, FilterCell {
    
    private struct Layout {
        static let titleLabelHorizontalInset: CGFloat = 15.0
        static let titleLabelVerticalInset: CGFloat = 15.0
        static let titleLabelFontSize: CGFloat = 17.0
        static let titleLabelHeight: CGFloat = 20.0
        
        static let attributeGridViewVerticalInset: CGFloat = 15.0
    }
    
    private let attributeGridView = ListingAttributeGridView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: Layout.titleLabelFontSize)
        label.textColor = .blackText
        return label
    }()
    
    var topSeparator: UIView?
    var bottomSeparator: UIView?
    var rightSeparator: UIView?
    
    private var selectionAction: ((ListingAttributeGridItem) -> Void)?
    private var deselectionAction: ((ListingAttributeGridItem) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupUI()
        attributeGridView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(withTitle title: String?,
               values: [ListingAttributeGridItem],
               selectedValues: [ListingAttributeGridItem],
               selectionAction: @escaping ((ListingAttributeGridItem) -> Void),
               deselectionAction: @escaping ((ListingAttributeGridItem) -> Void)) {
        titleLabel.text = title
        self.selectionAction = selectionAction
        self.deselectionAction = deselectionAction
        attributeGridView.setup(withItems: values,
                                selectedItems: selectedValues)
    }
    
    private func setupUI() {
        backgroundColor = .white
        addBottomSeparator(toContainerView: self)
    }
    
    private func setupConstraints() {
        addSubviewsForAutoLayout([attributeGridView, titleLabel])
        
        titleLabel.layout(with: self)
            .fillHorizontal(by: Layout.titleLabelHorizontalInset)
            .top(by: Layout.titleLabelVerticalInset)
        titleLabel.layout().height(Layout.titleLabelHeight)
        
        attributeGridView.layout(with: self)
            .fillHorizontal()
            .bottom(by: -Layout.attributeGridViewVerticalInset)
        attributeGridView.layout(with: titleLabel).top(to: .bottom,
                                                       by: Layout.attributeGridViewVerticalInset)
    }
    
    static func height(forItemCount itemCount: Int,
                       forContainerWidth containerWidth: CGFloat) -> CGFloat {
        let baseHeight = (Layout.attributeGridViewVerticalInset*2)
            + Layout.titleLabelVerticalInset
            + Layout.titleLabelHeight
        let gridHeight = ListingAttributeGridView.height(forItemCount: itemCount,
                                                         inContainerWidth: containerWidth)
        return baseHeight + gridHeight
    }
}


// MARK: - ListingAttributeGridViewDelegate Implementation

extension FilterAttributeGridCell: ListingAttributeGridViewDelegate {
    
    func didSelect(item: ListingAttributeGridItem) {
        selectionAction?(item)
    }
    
    func didDeselect(item: ListingAttributeGridItem) {
        deselectionAction?(item)
    }
}
