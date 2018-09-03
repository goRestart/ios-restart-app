
import UIKit

class ListingCarouselMoreInfoViewAttributeGridView: UIView {
    
    private struct Layout {
        static let titleLabelHorizontalOffset: CGFloat = 16.0
        static let titleLabelVerticalOffset: CGFloat = 16.0
        static let titleLabelHeight: CGFloat = 19.0
        static let gridCollectionViewVerticalOffset: CGFloat = 16.0
        static let separatorLineHeight: CGFloat = 1.0
        static let separatorXOffset: CGFloat = 16.0
    }
    
    private var tapAction: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private var gridCollectionView: ListingAttributeGridView?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawSeparators(inRect: rect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        performSetup()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


// MARK: - Actions

extension ListingCarouselMoreInfoViewAttributeGridView {
    
    func setup(withTitle title: String?,
               items: [ListingAttributeGridItem],
               tapAction: (() -> Void)?) {
        titleLabel.text = title
        self.tapAction = tapAction
        setupCollectionView(withItems: items)
    }

    private func setupCollectionView(withItems items: [ListingAttributeGridItem]) {
        resetCollectionView()
        gridCollectionView = ListingAttributeGridView(frame: CGRect.zero,
                                                      layoutBehaviour: ListingAttributeGridLayoutBehaviour.horizontalScroll,
                                                      theme: ListingAttributeGridTheme.dark,
                                                      items: items,
                                                      selectionEnabled: false)
        setupCollectionViewLayout()
        setupGestureRecognizer()
    }
    
    private func resetCollectionView() {
        gridCollectionView?.removeFromSuperview()
        gridCollectionView = nil
    }
    
    private func setupCollectionViewLayout() {
        guard let gridCollectionView = gridCollectionView else { return }
        addSubviewForAutoLayout(gridCollectionView)
        gridCollectionView.layout(with: self)
            .fillHorizontal()
            .bottom(to: .bottom,
                    by: -Layout.gridCollectionViewVerticalOffset)
        gridCollectionView.layout(with: titleLabel).top(to: .bottom,
                                                        by: Layout.gridCollectionViewVerticalOffset)
    }
    
    private func setupGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(didTapCollectionView))
        gestureRecognizer.cancelsTouchesInView = true
        gridCollectionView?.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func didTapCollectionView() {
        tapAction?()
    }
}


// MARK: - Setup

extension ListingCarouselMoreInfoViewAttributeGridView {
    
    private func performSetup() {
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentMode = UIViewContentMode.redraw
        clipsToBounds = true
    }
    
    private func setupConstraints() {
        addSubviewsForAutoLayout([titleLabel])
        
        titleLabel.layout(with: self)
            .fillHorizontal(by: Layout.titleLabelHorizontalOffset)
            .top(by: Layout.titleLabelVerticalOffset)
        
        titleLabel.layout().height(Layout.titleLabelHeight)
    }
}


// MARK: - Drawing

extension ListingCarouselMoreInfoViewAttributeGridView {
    
    private func drawSeparators(inRect rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setLineWidth(Layout.separatorLineHeight)
        
        let rect = rect.insetBy(dx: Layout.separatorXOffset, dy: 0)
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY-Layout.separatorLineHeight))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY-Layout.separatorLineHeight))
        
        context.strokePath()
    }
}
