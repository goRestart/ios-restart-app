import UIKit

final class WaterFallLayout: UICollectionViewLayout {
    
    private enum Element: String {
        case sectionHeader
        case sectionFooter
        case cell
    }

    private typealias ElementCache = [Element: [IndexPath: UICollectionViewLayoutAttributes]]
    private typealias SectionIndex = Int
    private typealias Boundary = (minimum: CGFloat, maximum: CGFloat)
    
    // MARK:- Private Properties

    private var unionRects: [NSValue]
    private let unionSize: Int
    private var oldBounds: CGRect

    private var cache = ElementCache()
    private var cachedSectionsIndexSet = Set<SectionIndex>()
    private var visibleLayoutAttributes: [UICollectionViewLayoutAttributes]

    private var sectionBoundaries: [SectionIndex: (min: CGFloat, max: CGFloat)]
    private var pinnedHeaderHeights: [SectionIndex: CGFloat]
    private var stickyHeaderHeights: [SectionIndex: CGFloat]

    private var columnHeights: [[CGFloat]]

    // MARK:- Private Computed Properties
    
    private var contentOffsetY: CGFloat { return collectionView?.contentOffset.y ?? 0 }
    private var numberOfSections: Int { return collectionView?.numberOfSections ?? 0 }

    private var cacheCount: Int {
        let headers = cache[.sectionHeader]?.count ?? 0
        let footers = cache[.sectionFooter]?.count ?? 0
        let cells = cache[.cell]?.count ?? 0
        return headers + footers + cells
    }
    
    private var totalItemsCount: Int {
        guard let collectionView = collectionView else { return 0 }
        return (0 ..< numberOfSections).reduce(0) {
            return $0 + collectionView.numberOfItems(inSection: $1)
        }
    }

    private var hasStickyHeader: Bool {
        guard let collectionView = collectionView else { return false }
        let headerTypes = (0 ..< numberOfSections).compactMap { section in
            return delegate?.collectionView(collectionView, headerStickynessForSectionAt: section)
        }
        return headerTypes.contains(.pinned) || headerTypes.contains(.sticky)
    }
    
    private var shouldInvalidateCache: Bool {
        guard cachedSectionsIndexSet.count == numberOfSections else { return true }
        return cache[.cell]?.count != totalItemsCount
    }

    
    // MARK:- Public Property
    
    weak var delegate: WaterFallLayoutDelegate? {
        return collectionView?.delegate as? WaterFallLayoutDelegate
    }
    
    var isTopHeaderStrechy: Bool {
        didSet {
            guard isTopHeaderStrechy != oldValue else { return }
            invalidateLayout()
        }
    }
    
    var itemRenderPolicy: WaterfallLayoutItemRenderPolicy {
        didSet {
            guard itemRenderPolicy != oldValue else { return }
            invalidateLayout()
        }
    }

    // MARK: - Init
    
    override init() {
        self.unionSize = 20
        self.oldBounds = .zero
        self.unionRects = []
        self.columnHeights = []
        self.visibleLayoutAttributes = []
        self.sectionBoundaries = [:]
        self.pinnedHeaderHeights = [:]
        self.stickyHeaderHeights = [:]
        self.isTopHeaderStrechy = WaterFallLayoutSettings.topHeaderIsStretchy
        self.itemRenderPolicy = WaterFallLayoutSettings.itemRenderPolicy
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    // MARK: - Required Overrides
    
    override var collectionViewContentSize: CGSize {
        guard numberOfSections > 0 else { return .zero }
        guard let totalHeight = columnHeights.last?.max(), totalHeight > 0 else { return .zero }
        var contentSize = collectionView?.bounds.size ?? .zero
        contentSize.height = totalHeight
        return contentSize
    }

    override public func prepare() {
        super.prepare()
        guard let collectionView = collectionView, shouldInvalidateCache else { return }

        prepareCache()
        
        oldBounds = collectionView.bounds
        guard numberOfSections > 0 else { return }
        var contentHeight: CGFloat = 0.0
        for section in 0 ..< numberOfSections {
            let columnCount = self.columnCount(in: section)
            prepareSectionIndexSet(section)
            prepareColumnHeightsArray(forSection: section, withColumnCount: columnCount)
            prepareSupplementaryViewAttributes(.sectionHeader,
                                     collectionView: collectionView,
                                     inSection: section,
                                     collectionViewContentHeight: &contentHeight)
            prepareCellItemAttributes(collectionView,
                                      inSection: section,
                                      collectionViewContentHeight: &contentHeight)
            prepareSupplementaryViewAttributes(.sectionFooter,
                                     collectionView: collectionView,
                                     inSection: section,
                                     collectionViewContentHeight: &contentHeight)
            updateColumnHeightsInSection(section,
                                columnCount: columnCount,
                                collectionViewContentHeight: contentHeight)
        }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[.cell]?[indexPath]
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                       at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        var attributes: UICollectionViewLayoutAttributes?
        switch elementKind {
        case UICollectionElementKindSectionHeader:
            attributes = cache[.sectionHeader]?[indexPath]
        case UICollectionElementKindSectionFooter:
            attributes = cache[.sectionFooter]?[indexPath]
        default: break
        }
        return attributes ?? UICollectionViewLayoutAttributes()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        visibleLayoutAttributes.removeAll(keepingCapacity: true)
        visibleLayoutAttributes.append(contentsOf: updatedHeadersAttributes())
        visibleLayoutAttributes.append(contentsOf: updatedNonHeaderAttributes(in: rect))
        return visibleLayoutAttributes
    }

    override public func shouldInvalidateLayout (forBoundsChange newBounds: CGRect) -> Bool {
        if oldBounds.size != newBounds.size {
            cache.removeAll(keepingCapacity: true)
        }
        return true
    }
}


// MARK:- Helpers For Sticky, Pinned Header Layout Calculation

extension WaterFallLayout {
    
    /// Set Scrolling behaviour for section headers in collectionview depending on the header type (nonSticky, sticky or pinned)
    private func setHeaderScrollingBehaviour(_ collectionView: UICollectionView,
                                             inSection section: Int,
                                             headerFrame frame: inout CGRect,
                                             headerType type: HeaderStickyType) {
        guard let boundaries = sectionItemsBoundaries(collectionView, inSection: section) else { return }
        switch type {
        case .pinned:
            setPinnedHeader(withinBoundary: boundaries, headerFrame: &frame, section: section)
        case .sticky:
            setStickyHeader(withinBoundary: boundaries, headerFrame: &frame, section: section)
        case .nonSticky: break
        }
    }
    
    private func sectionItemsBoundaries(_ collectionView: UICollectionView,
                                        inSection section: Int) -> Boundary? {
        guard collectionView.numberOfItems(inSection: section) > 0 else { return nil }
        guard let min = sectionBoundaries[section]?.min, let max = sectionBoundaries[section]?.max else {
            return nil
        }
        return (min, max)
    }
    
    /// Set the frame of Pinned header in a given section
    private func setPinnedHeader(withinBoundary boundaries: Boundary, headerFrame: inout CGRect, section: Int) {
        
        if section == 0 {
            setPinnedHeaderInTopSection(headerFrame: &headerFrame)
        } else {
            let accumulatedHeaderHeight = totalPinnedHeaderHeights(aboveSection: section)
            let minimumOffset = boundaries.minimum - headerFrame.height - accumulatedHeaderHeight
            if contentOffsetY >= minimumOffset {
                snapFrame(&headerFrame, withOffset: accumulatedHeaderHeight)
            } else {
                setFrameOriginY(&headerFrame, toOffset: minimumOffset + accumulatedHeaderHeight)
            }
        }
    }
    
    /// Set the frame of Pinned header in section 0
    private func setPinnedHeaderInTopSection(headerFrame: inout CGRect) {
        guard let collectionView = collectionView else { return }
        snapFrame(&headerFrame, withOffset: totalPinnedHeaderHeights(aboveSection: 0))
        let headerHeight = delegate?.collectionView(collectionView, layout: self, heightForHeaderForSectionAt: 0) ?? WaterFallLayoutSettings.headerHeight
        if isTopHeaderStrechy && contentOffsetY < 0 {
            headerFrame.size.height = headerHeight - contentOffsetY // Stretch
        } else {
            headerFrame.size.height = headerHeight
        }
    }
    
    /// Set the frame of sticky header in a given section
    private func setStickyHeader(withinBoundary boundaries: Boundary, headerFrame: inout CGRect, section: Int) {
        
        let accumulatedHeaderHeight = totalPinnedHeaderHeights(aboveSection: section)
        let minimumOffset = boundaries.minimum - headerFrame.height - accumulatedHeaderHeight
        let maximumOffset = boundaries.maximum - headerFrame.height - accumulatedHeaderHeight

        if contentOffsetY <= minimumOffset {
            setFrameOriginY(&headerFrame, toOffset: minimumOffset + accumulatedHeaderHeight)
        } else if contentOffsetY <= maximumOffset {
            snapFrame(&headerFrame, withOffset: accumulatedHeaderHeight)
        } else if contentOffsetY > maximumOffset {
            setFrameOriginY(&headerFrame, toOffset: maximumOffset + accumulatedHeaderHeight)
        }
    }
    
    // Header Heights above a given section
    
    /// Total heights of pinned headers above a given section
    private func totalPinnedHeaderHeights(aboveSection section: Int) -> CGFloat {
        return pinnedHeaderHeights
                .filter { return $0.key < section }
                .map{ $0.value }
                .reduce(0, +)
    }
    
    /// Total heights of visible headers above a given section
    private func totalFixedHeaderHeights(aboveSection section: Int) -> CGFloat {
        let heightOfStickyHeader = stickyHeaderHeights[section] ?? 0
        return totalPinnedHeaderHeights(aboveSection: section) + heightOfStickyHeader
    }
    
    // Set header origin Y

    /// snap frame with a fixed offset to the origin of collectionView frame
    private func snapFrame(_ frame: inout CGRect, withOffset offset: CGFloat) {
        frame.origin.y = contentOffsetY + offset
    }
    
    /// set frame y with a fixed offset so that it scrolls with collectionview
    private func setFrameOriginY(_ frame: inout CGRect, toOffset offset: CGFloat) {
        frame.origin.y = offset
    }
}


// MARK:- Helpers For WaterFall Layout

extension WaterFallLayout {
    
    private func prepareSectionIndexSet(_ section: Int) {
        cachedSectionsIndexSet.insert(section)
    }
    
    private func prepareCache() {
        cache.removeAll(keepingCapacity: true)
        cache[.sectionHeader] = [IndexPath: UICollectionViewLayoutAttributes]()
        cache[.sectionFooter] = [IndexPath: UICollectionViewLayoutAttributes]()
        cache[.cell] = [IndexPath: UICollectionViewLayoutAttributes]()
        unionRects = []
        columnHeights = []
        pinnedHeaderHeights = [:]
    }
    
    // Prepare All elements: Cell, Header and Footer
    
    /// Calculate the attributes frame of supplementary view in a given section
    private func prepareSupplementaryViewAttributes(_ type: Element,
                                          collectionView: UICollectionView, inSection: Int, collectionViewContentHeight: inout CGFloat) {
        var attributes = UICollectionViewLayoutAttributes()
        var height: CGFloat = 0
        switch type {
        case .sectionHeader:
            attributes = UICollectionViewLayoutAttributes.buildForHeader(inSection: inSection)
            height = delegate?.collectionView(collectionView,
                                              layout: self,
                                              heightForHeaderForSectionAt: inSection) ?? WaterFallLayoutSettings.headerHeight
        case .sectionFooter:
            attributes = UICollectionViewLayoutAttributes.buildForFooter(inSection: inSection)
            height = delegate?.collectionView(collectionView,
                                              layout: self,
                                              heightForFooterInSection: inSection) ?? WaterFallLayoutSettings.footerHeight
        case .cell: break
        }
        prepareElementLayoutAttributes(origin: CGPoint(x: 0, y: collectionViewContentHeight),
                       size: CGSize(width: collectionView.bounds.width, height: height),
                       type: type,
                       attributes: attributes,
                       collectionViewContentHeight: &collectionViewContentHeight)
    }

    private func prepareCellItemAttributes(_ collectionView: UICollectionView, inSection section: Int, collectionViewContentHeight: inout CGFloat) {
        
        // calculate section based metrics
        let itemCount = collectionView.numberOfItems(inSection: section)
        let columnCount = self.columnCount(in: section)
        let minimumLineSpacing = self.minimumLineSpacing(in: section)
        let sectionInsets = self.sectionInsets(in: section)
        
        let upperSectionBoundary = collectionViewContentHeight
        collectionViewContentHeight += sectionInsets.top
        updateColumnHeightsInSection(section, columnCount: columnCount, collectionViewContentHeight: collectionViewContentHeight)
        
        for idx in 0 ..< itemCount {
            let indexPath = IndexPath(item: idx, section: section)
            let columnIndex = nextColumnIndexForItem(idx, section: section)
            let itemFrame = self.itemFrame(collectionView, atIndexPath: indexPath, sectionInsets: sectionInsets, columnCount: columnCount, columnIndex: columnIndex)
            let attributes = UICollectionViewLayoutAttributes.buildForCell(atIndexPath: indexPath)
            prepareElementLayoutAttributes(origin: itemFrame.origin, size: itemFrame.size, type: .cell, attributes: attributes, collectionViewContentHeight: &collectionViewContentHeight)
            columnHeights[section][columnIndex] = attributes.frame.maxY + minimumLineSpacing
        }
        
        let columnIndex  = self.longestColumnIndexInSection(section)
        collectionViewContentHeight = columnHeights[section][columnIndex] - minimumLineSpacing + sectionInsets.bottom
        sectionBoundaries[section] = (min: upperSectionBoundary, max: collectionViewContentHeight)
    }
    
    private func itemFrame(_ collectionView: UICollectionView, atIndexPath indexPath: IndexPath, sectionInsets: UIEdgeInsets, columnCount: Int, columnIndex: Int) -> CGRect {
        let section = indexPath.section
        let itemWidth = self.itemWidth(collectionView, sectionInsets: sectionInsets, columnCount: columnCount, section: section)
        let xOffset = sectionInsets.left + (itemWidth + WaterFallLayoutSettings.minimumColumnSpacing) * CGFloat(columnIndex)
        let yOffset = ((self.columnHeights[section] as AnyObject).object (at: columnIndex) as AnyObject).doubleValue ?? 0
        let itemSize = self.itemSize(collectionView, atIndexPath: indexPath, itemWidth: itemWidth)
        return CGRect(origin: CGPoint(x: xOffset, y: CGFloat(yOffset)),
                                       size: itemSize)
    }
    
    private func prepareElementLayoutAttributes(origin: CGPoint,
                                size: CGSize,
                                type: Element,
                                attributes: UICollectionViewLayoutAttributes,
                                collectionViewContentHeight: inout CGFloat) {
        guard size.height > 0 else { return }
        attributes.frame = CGRect(origin: origin, size: size)
        cache[type]?[attributes.indexPath] = attributes
        if type != .cell {
            collectionViewContentHeight += size.height
        }
    }
    
    private func updatedHeadersAttributes() -> [UICollectionViewLayoutAttributes] {
        var headerAttributes: [UICollectionViewLayoutAttributes] = []
        guard let collectionView = collectionView else { return headerAttributes }
        for section in cachedSectionsIndexSet {
            let indexPath = IndexPath(item: 0, section: section)
            if let sectionHeaderAttributes = cache[.sectionHeader]?[indexPath] {
                let headerType = delegate?.collectionView(collectionView, headerStickynessForSectionAt: section) ?? .nonSticky
                let headerHeight = sectionHeaderAttributes.frame.height
                switch headerType {
                case .pinned:
                    sectionHeaderAttributes.zIndex = headerType.headerZIndex
                    pinnedHeaderHeights[section] = headerHeight
                case .sticky:
                    sectionHeaderAttributes.zIndex = headerType.headerZIndex
                    stickyHeaderHeights[section] = headerHeight
                case .nonSticky: break
                }
                setHeaderScrollingBehaviour(collectionView,
                                            inSection: section,
                                            headerFrame: &sectionHeaderAttributes.frame,
                                            headerType: headerType)
                headerAttributes.append(sectionHeaderAttributes)
            }
        }
        return headerAttributes
    }
    
    private func updatedNonHeaderAttributes(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        var nonHeaderAttributes = [UICollectionViewLayoutAttributes]()
        let nonHeaderCache = cache.filter { $0.key != .sectionHeader }
        for (_, elementInfos) in nonHeaderCache {
            for (_, attributes) in elementInfos where attributes.frame.intersects(rect) {
                nonHeaderAttributes.append(attributes)
            }
        }
        return nonHeaderAttributes
    }
}

extension WaterFallLayout {

    private func itemWidth(_ collectionView: UICollectionView,
                           sectionInsets: UIEdgeInsets,
                           columnCount: Int,
                           section: Int) -> CGFloat {
        let width = collectionView.bounds.size.width - sectionInsets.left - sectionInsets.right
        return floor((width - (CGFloat(columnCount - 1) * WaterFallLayoutSettings.minimumColumnSpacing)) / CGFloat(columnCount))
    }

    private func prepareColumnHeightsArray(forSection section: Int, withColumnCount: Int) {
        let columnCount = self.columnCount(in: section)
        let sectionColumnHeights = [CGFloat](repeating: 0, count: columnCount)
        columnHeights.append(sectionColumnHeights)
    }

    private func updateColumnHeightsInSection(_ section: Int, columnCount: Int, collectionViewContentHeight: CGFloat) {
        for idx in 0 ..< columnCount {
            columnHeights[section][idx] = collectionViewContentHeight
        }
    }

    private func columnCount(in section: Int) -> Int {
        let defaultColumnCount = WaterFallLayoutSettings.columnCount
        guard let collectionView = collectionView else { return defaultColumnCount }
        if let columnCount = delegate?.collectionView(collectionView, layout: self, columnCountForSectionAt: section) {
            return columnCount
        } else {
            return defaultColumnCount
        }
    }
    
    private func itemSize(_ collectionView: UICollectionView, atIndexPath indexPath: IndexPath, itemWidth: CGFloat) -> CGSize {

        var itemSize = delegate?.collectionView(collectionView, layout: self, sizeForItemAtIndexPath: indexPath) ?? WaterFallLayoutSettings.itemSize
        let defaultHeight = itemSize.height
        let defaultWidth = itemSize.width
        
        if defaultHeight > 0, defaultWidth > 0 {
            let aspectRatio = defaultHeight / defaultWidth
            itemSize = CGSize(width: itemWidth, height: floor(aspectRatio * itemWidth))
        }
        return itemSize
    }
    
    private func sectionInsets(in section: Int) -> UIEdgeInsets {
        guard let collectionView = collectionView else { return .zero }
        return delegate?.collectionView(collectionView,
                                 layout: self,
                                 insetForSectionAt: section) ?? WaterFallLayoutSettings.sectionInset
    }
    
    private func minimumLineSpacing(in section: Int) -> CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return delegate?.collectionView(collectionView,
                                 layout: self,
                                 minimumLineSpacingForSectionAt: section) ?? WaterFallLayoutSettings.minimumLineSpacing
    }
}

extension WaterFallLayout {

    func nextColumnIndexForItem (_ item: Int, section: Int) -> Int {
        var index = 0
        let columnCount = self.columnCount(in: section)
        
        switch itemRenderPolicy {
        case .shortestFirst:
            index = self.shortestColumnIndexInSection(section)
        case .leftToRight :
            index = (item%columnCount)
        case .rightToLeft:
            index = (columnCount - 1) - (item % columnCount)
        }
        return index
    }
    
    func longestColumnIndexInSection (_ section: Int) -> Int {
        guard let maxHeight = columnHeights[section].max(),
            let columnIndex = columnHeights[section].index(of: maxHeight) else {
                return 0
        }
        return columnIndex
    }
    
    func shortestColumnIndexInSection (_ section: Int) -> Int {
        guard let minHeight = columnHeights[section].min(),
            let columnIndex = columnHeights[section].index(of: minHeight) else {
                return 0
        }
        return columnIndex
    }
    
    func yOffsetForTopItemInSection(_ section: Int) -> CGFloat {
        let indexPath = IndexPath(item: 0, section: section)
        guard let itemAttributes = cache[.cell]?[indexPath] else {
            return 0
        }
        return itemAttributes.frame.origin.y
    }
    
    /// Bottom Y of the header in the last section
    func lastHeaderBottomY() -> CGFloat {
        let lastSection = numberOfSections - 1
        guard lastSection >= 0 else { return 0 }
        return yOffsetForTopItemInLastSection() - sectionInsets(in: lastSection).top
    }
    
    func yOffsetForTopItemInLastSection() -> CGFloat {
        return yOffsetForTopItemInSection(numberOfSections - 1)
    }
    
    /// Minimum required distance from the top item in the last section of collectionView to collectionView origin Y.
    /// For example, if the previous sections have pinned headers, the minimum distance will be the total height of all pinned headers plus the top sectionInset of the last section.
    func minYOffsetForTopItemInLastSection() -> CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let finalSection = numberOfSections - 1
        let sectionInsets = delegate?.collectionView(collectionView, layout: self, insetForSectionAt: finalSection) ?? WaterFallLayoutSettings.sectionInset
        return totalFixedHeaderHeights(aboveSection: finalSection)
                + sectionInsets.top
    }
    
    /// The Y location of refresh control.
    /// If there are no pinned headers, it works as normal refresh control.
    /// If there are pinned headers, it stays below the last pinned header.
    func refreshControlOriginY() -> CGFloat {
        return totalPinnedHeaderHeights(aboveSection: numberOfSections - 1)
    }
}
