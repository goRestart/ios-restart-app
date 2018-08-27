import UIKit

/// This LGWaterFallLayout gives the possibility to align sections (instead of cells) according to waterfall layout
/// This gives us the possibility to insert eg. full width items in our previous infinite 2 (or 3) columns waterfall layout region
/// Thus gives us the flexibility to adapt to any future business requirement.

/// To use it, specify for each section if it should be waterfall or fullscreen (number of columns). then the layout will
/// do the rest for you.

/// You can also set if header of a section is sticky or pinned.

final class LGWaterFallLayout: UICollectionViewLayout {

    private typealias ElementCache = [Element: [IndexPath: UICollectionViewLayoutAttributes]]
    private typealias SectionIndex = Int
    private typealias Boundary = (minimum: CGFloat, maximum: CGFloat)

    private enum Element: String {
        case sectionHeader, sectionFooter, cell
    }


    // MARK:- Private Properties

    private var cache = ElementCache()
    private var visibleLayoutAttributes: [UICollectionViewLayoutAttributes]
    private var cachedSectionsIndexSet = Set<SectionIndex>()

    private var oldBounds: CGRect
    private var columnHeights: [[CGFloat]]
    private var numberOfSectionsInCurrentBlock: Int = 0

    private var pinnedHeaderHeights: [SectionIndex: CGFloat]
    private var stickyHeaderHeights: [SectionIndex: CGFloat]
    private var sectionBoundaries: [SectionIndex: (min: CGFloat, max: CGFloat)]

    private var numberOfSections: Int { return collectionView?.numberOfSections ?? 0 }
    private var contentOffsetY: CGFloat { return collectionView?.contentOffset.y ?? 0 }

    private var totalItemsCount: Int {
        guard let collectionView = collectionView else { return 0 }
        return (0 ..< numberOfSections).reduce(0) {
            return $0 + collectionView.numberOfItems(inSection: $1)
        }
    }

    private var shouldInvalidateCache: Bool {
        guard cachedSectionsIndexSet.count == numberOfSections else { return true }
        return cache[.cell]?.count != totalItemsCount
    }

    private var currentBlockColumnHeights: [CGFloat]? {
        return columnHeights.last
    }

    private var bottomYOfPreviousBlock: CGFloat {
        return columnHeights.last?.max() ?? 0
    }


    // MARK:- Public Property

    var itemRenderPolicy: WaterfallLayoutItemRenderPolicy {
        didSet {
            guard itemRenderPolicy != oldValue else { return }
            invalidateLayout()
        }
    }

    weak var delegate: LGWaterFallLayoutDelegate? {
        return collectionView?.delegate as? LGWaterFallLayoutDelegate
    }

    var isTopHeaderStretchy: Bool {
        didSet {
            guard isTopHeaderStretchy != oldValue else { return }
            invalidateLayout()
        }
    }


    // MARK: - Life Cycle

    override init() {
        self.oldBounds = .zero
        self.columnHeights = []
        self.visibleLayoutAttributes = []
        self.pinnedHeaderHeights = [:]
        self.stickyHeaderHeights = [:]
        self.sectionBoundaries = [:]
        self.itemRenderPolicy = LGWaterFallSettings.itemRenderPolicy
        self.isTopHeaderStretchy = LGWaterFallSettings.topHeaderIsStretchy
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    // MARK: - UICollectionViewLayout Required Setups

    override var collectionViewContentSize: CGSize {
        guard numberOfSections > 0 else { return .zero }
        guard let totalHeight = columnHeights.last?.max(), totalHeight > 0 else { return .zero }
        var contentSize = collectionView?.bounds.size ?? .zero
        contentSize.height = totalHeight
        return contentSize
    }

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView, shouldInvalidateCache else { return }

        clearCache()
        oldBounds = collectionView.bounds

        guard numberOfSections > 0 else { return }
        var contentHeight: CGFloat = 0.0

        for section in 0 ..< numberOfSections {
            cacheSectionIndex(section)
            if isSectionInNewBlock(section: section) {
                contentHeight = bottomYOfPreviousBlock
                let columnCount = blockColumnCount(forSection: section)
                prepareColumnHeightsArray(with: columnCount, contentHeight: contentHeight)
                numberOfSectionsInCurrentBlock = 0
            } else {
                numberOfSectionsInCurrentBlock += 1
            }

            let columnIndex = nextColumnIndexInBlock(forSection: section)
            let sectionXOffset = calculateXOffset(collectionView, for: section)
            let sectionYOffset = calculateYOffset(for: section)
            let sectionWidth = calculateWidth(collectionView, for: section)
            var sectionBottom: CGFloat = sectionYOffset
            prepareSupplementaryViewAttributes(.sectionHeader,
                                               collectionView: collectionView,
                                               section: section,
                                               xOffset: sectionXOffset,
                                               width: sectionWidth,
                                               sectionBottom: &sectionBottom)

            prepareCellItemAttributes(collectionView,
                                      inSection: section,
                                      xOffset: sectionXOffset,
                                      width: sectionWidth,
                                      sectionBottom: &sectionBottom)

            prepareSupplementaryViewAttributes(.sectionFooter,
                                               collectionView: collectionView,
                                               section: section,
                                               xOffset: sectionXOffset,
                                               width: sectionWidth,
                                               sectionBottom: &sectionBottom)

            updateColumnHeights(columnIndex: columnIndex,
                                contentHeight: sectionBottom)
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

    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if oldBounds.size != newBounds.size {
            cache.removeAll(keepingCapacity: true)
        }
        return true
    }
}


// MARK:- Prepare Layout Attributes for cell and supplementary View

extension LGWaterFallLayout {

    private func prepareSupplementaryViewAttributes(_ type: Element,
                                                    collectionView: UICollectionView,
                                                    section: Int,
                                                    xOffset: CGFloat,
                                                    width: CGFloat,
                                                    sectionBottom: inout CGFloat) {
        var attributes = UICollectionViewLayoutAttributes()
        var height: CGFloat = 0
        switch type {
        case .sectionHeader:
            attributes = UICollectionViewLayoutAttributes.buildForHeader(inSection: section)
            height = delegate?.collectionView(collectionView,
                                              layout: self,
                                              heightForHeaderForSectionAt: section) ?? 0
        case .sectionFooter:
            attributes = UICollectionViewLayoutAttributes.buildForFooter(inSection: section)
            height = delegate?.collectionView(collectionView,
                                              layout: self,
                                              heightForFooterInSection: section) ?? 0
        case .cell: break
        }

        prepareElement(origin: CGPoint(x: xOffset, y: sectionBottom),
                       size: CGSize(width: width, height: height),
                       type: type,
                       attributes: attributes)
        sectionBottom += height
    }

    private func prepareCellItemAttributes(_ collectionView: UICollectionView,
                                           inSection section: Int,
                                           xOffset: CGFloat,
                                           width: CGFloat,
                                           sectionBottom: inout CGFloat) {
        // Important: If there is more than 1 cell in a section,
        // cells will be vertically stacked and take the whole section width

        let itemCount = collectionView.numberOfItems(inSection: section)
        let minimumLineSpacing = delegate?.collectionView(collectionView,
                                                          layout: self,
                                                          minimumLineSpacingForSectionAt: section) ?? LGWaterFallSettings.minimumLineSpacing
        let sectionInsets = self.sectionInsets(in: section)

        let upperSectionBoundary = sectionBottom
        sectionBottom += sectionInsets.top

        for idx in 0 ..< itemCount {
            let indexPath = IndexPath(item: idx, section: section)
            let attributes = UICollectionViewLayoutAttributes.buildForCell(atIndexPath: indexPath)
            let cellSize = self.cellSize(collectionView, atIndexPath: indexPath, sectionWidth: width)
            let cellFrame = CGRect(origin: CGPoint(x: xOffset + sectionInsets.left,
                                                   y: sectionBottom),
                                   size: cellSize)
            prepareElement(origin: cellFrame.origin,
                           size: cellFrame.size,
                           type: .cell,
                           attributes: attributes)
            sectionBottom += (cellFrame.size.height + minimumLineSpacing)
        }
        sectionBottom += sectionInsets.bottom
        sectionBoundaries[section] = (min: upperSectionBoundary, max: sectionBottom)
    }

    private func cellSize(_ collectionView: UICollectionView,
                          atIndexPath indexPath: IndexPath,
                          sectionWidth: CGFloat) -> CGSize {

        let cellWidth = sectionWidth - sectionInsets(in: indexPath.section).left - sectionInsets(in: indexPath.section).right
        var cellSize = delegate?.collectionView(collectionView, layout: self, sizeForItemAtIndexPath: indexPath) ?? LGWaterFallSettings.itemSize
        let defaultHeight = cellSize.height
        let defaultWidth = cellSize.width
        if defaultHeight > 0, defaultWidth > 0 {
            let aspectRatio = defaultHeight / defaultWidth
            cellSize = CGSize(width: cellWidth, height: floor(aspectRatio * cellWidth))
        }
        return cellSize
    }

    private func prepareElement(origin: CGPoint,
                                size: CGSize,
                                type: Element,
                                attributes: UICollectionViewLayoutAttributes) {
        guard size.height > 0 else { return }
        attributes.frame = CGRect(origin: origin, size: size)
        cache[type]?[attributes.indexPath] = attributes
    }
}


// MARK:- Prepare, update and clear variables

extension LGWaterFallLayout {

    private func clearCache() {
        cache.removeAll(keepingCapacity: true)
        cache[.sectionHeader] = [:]
        cache[.sectionFooter] = [:]
        cache[.cell] = [:]
        columnHeights = []
        pinnedHeaderHeights = [:]
    }

    private func cacheSectionIndex(_ section: Int) {
        cachedSectionsIndexSet.insert(section)
    }

    private func prepareColumnHeightsArray(with columnCount: Int, contentHeight: CGFloat) {
        let blockColumnHeights = [CGFloat](repeating: contentHeight, count: columnCount)
        columnHeights.append(blockColumnHeights)
    }

    private func updateColumnHeights(columnIndex: Int, contentHeight: CGFloat) {
        let nrBlocks = columnHeights.count
        guard nrBlocks > 0, columnIndex < columnHeights[nrBlocks-1].count else { return }
        columnHeights[nrBlocks-1][columnIndex] = contentHeight
    }

    private func updatedHeadersAttributes() -> [UICollectionViewLayoutAttributes] {
        var headerAttributes: [UICollectionViewLayoutAttributes] = []
        guard let collectionView = collectionView else { return headerAttributes }
        for section in cachedSectionsIndexSet {
            let indexPath = IndexPath(item: 0, section: section)
            if let sectionHeaderAttributes = cache[.sectionHeader]?[indexPath],
                isFullScreenWidth(section: section) {
                let headerType = headerTypeForSection(section)
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


// MARK:- Helpers For Sticky, Pinned Header Layout Calculation

extension LGWaterFallLayout {
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
        guard let min = sectionBoundaries[section]?.min,
            let max = sectionBoundaries[section]?.max else {  return nil  }
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
        let headerHeight = delegate?.collectionView(collectionView, layout: self, heightForHeaderForSectionAt: 0) ?? LGWaterFallSettings.headerHeight
        if isTopHeaderStretchy && contentOffsetY < 0 {
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


// MARK:- Helpers for retrieving info from IGListWaterFallLayoutDelegate

extension LGWaterFallLayout {
    private func blockColumnCount(forSection section: Int) -> Int {
        let defaultColumnCount = LGWaterFallSettings.columnCount
        guard let collectionView = collectionView else { return defaultColumnCount }
        return delegate?.collectionView(collectionView,
                                        layout: self,
                                        columnCountForSectionAt: section) ?? defaultColumnCount
    }

    private func sectionInsets(in section: Int) -> UIEdgeInsets {
        guard let collectionView = collectionView else { return .zero }
        return delegate?.collectionView(collectionView,
                                        layout: self,
                                        insetForSectionAt: section) ?? LGWaterFallSettings.sectionInset
    }
    
    private func headerTypeForSection(_ section: Int) -> HeaderStickyType {
        guard let collectionView = collectionView else { return .nonSticky }
        return delegate?.collectionView(collectionView, headerStickynessForSectionAt: section) ?? .nonSticky
    }
}


// MARK:- General calculation Helpers

extension LGWaterFallLayout {

    private func isSectionInNewBlock(section: Int) -> Bool {
        guard section > 0 else { return true }
        return blockColumnCount(forSection: section) != blockColumnCount(forSection: section-1)
    }

    private func isFullScreenWidth(section: Int) -> Bool {
        return blockColumnCount(forSection: section) == 1
    }

    private func nextColumnIndexInBlock(forSection section: Int) -> Int {
        let index: Int
        let columnCount = blockColumnCount(forSection: section)
        switch itemRenderPolicy {
        case .shortestFirst:
            index = self.shortestColumnIndexInBlock()
        case .leftToRight:
            index = (numberOfSectionsInCurrentBlock % columnCount)
        case .rightToLeft:
            index = (columnCount - 1) - (numberOfSectionsInCurrentBlock % columnCount)
        }
        return index
    }

    private func shortestColumnIndexInBlock () -> Int {
        guard let minHeight = currentBlockColumnHeights?.min(),
            let columnIndex = currentBlockColumnHeights?.index(of: minHeight)
            else { return 0 }
        return columnIndex
    }

    private func calculateXOffset(_ collectionView: UICollectionView,
                                  for section: Int) -> CGFloat {
        let columnIndex = nextColumnIndexInBlock(forSection: section)
        let sectionWidth = calculateWidth(collectionView, for: section)
        let insetLeft = isFullScreenWidth(section: section) ? 0 : SectionControllerLayout.sectionInset.left
        return insetLeft + (sectionWidth + SectionControllerLayout.fixedListingSpacing) * CGFloat(columnIndex)
    }

    private func calculateYOffset(for section: Int) -> CGFloat {
        let columnIndex = nextColumnIndexInBlock(forSection: section)
        return currentBlockColumnHeights?[columnIndex] ?? 0
    }

    private func calculateWidth(_ collectionView: UICollectionView,
                                for section: Int) -> CGFloat {
        guard !isFullScreenWidth(section: section) else {
            return collectionView.bounds.size.width
        }
        let columnCount = blockColumnCount(forSection: section)
        let containerWidth = collectionView.bounds.size.width - SectionControllerLayout.sectionInset.left - SectionControllerLayout.sectionInset.right
        return floor((containerWidth - (CGFloat(columnCount - 1) * SectionControllerLayout.fixedListingSpacing)) / CGFloat(columnCount))
    }
}
