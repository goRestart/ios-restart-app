import LGComponents
import RxSwift

struct LGSmokeTestCellLayout {
    let insets: UIEdgeInsets
    let verticalInsetDelta: CGFloat
}

final class LGSmokeTestLayout: UICollectionViewFlowLayout {
    
    private let easeInQuad: EasingFunction = { t in return t * t }
    
    private var cache = [UICollectionViewLayoutAttributes]()
    private var shouldInvalidateCache: Bool { return cache.count != numberOfItems }
    private var cellLayout: LGSmokeTestCellLayout
    
    private let centerRatio: CGFloat = 0.5
    private var numberOfItems: Int { get { return collectionView?.numberOfItems(inSection: 0) ?? 0 } }
    
    var page: Int { return Int(pageOffset(givenOffset: collectionView?.contentOffset.x ?? 0)) }
    var interitemSpacing: CGFloat { get { return cellLayout.insets.left / 2.0 } }
    var visibleWidth: CGFloat { get { return (collectionView?.bounds.width ?? 375) } }
    var visibleHeight: CGFloat { get { return (collectionView?.bounds.height ?? 750) } }
    
    var cellWidth: CGFloat { return visibleWidth - 2*cellLayout.insets.left }
    var cellHeight: CGFloat { return visibleHeight - cellLayout.insets.top }
    
    override var collectionViewContentSize : CGSize {
        let count = CGFloat(numberOfItems)
        let width = count * cellWidth + (count - 1) * cellLayout.insets.left/2 + 2*cellLayout.insets.left
        return CGSize(width: width, height: cellHeight)
    }
    
    convenience init(cellLayout: LGSmokeTestCellLayout) {
        self.init()
        self.cellLayout = cellLayout
    }
    
    override init() {
        let insets = UIEdgeInsets(top: 16.0, left: 32.0, bottom: 32.0, right: 32.0)
        self.cellLayout = LGSmokeTestCellLayout(insets: insets, verticalInsetDelta: insets.top)
        super.init()
        
        self.scrollDirection = .horizontal
        self.collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        self.collectionView?.alwaysBounceHorizontal = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        if shouldInvalidateCache {
            cache.removeAll(keepingCapacity: false)
            for item in 0..<numberOfItems {
                let indexPath = IndexPath(item: item, section: 0)
                cache.append(attributesForItem(at: indexPath))
            }
        } else {
            cache.forEach { attribute in
                update(attributes: attribute, forItemAt: attribute.indexPath)
            }
        }
    }
    
    func pageOffset(givenOffset x: CGFloat) -> CGFloat {
        let offset: CGFloat =  x
        let pageWidth: CGFloat = cellWidth + interitemSpacing
        let finalOffset = offset + pageWidth/2.0 // because of the first page initial position
        return CGFloat(finalOffset / pageWidth)
    }
    
    private func yInsetForItem(withInitialX initialX: CGFloat) -> CGFloat {
        let factor = offsetFactorForItem(withInitialX: initialX)
        
        let minimum = cellLayout.insets.top - cellLayout.verticalInsetDelta
        let leftInset = min(minimum + ((0.5 - factor) * cellLayout.insets.top), cellLayout.insets.top)
        let rightInset = min(minimum + ((factor - 0.5) * cellLayout.insets.top), cellLayout.insets.top)
        let inset = factor < centerRatio ? leftInset : rightInset
        return inset
    }
    
    private func alphaForItem(withInitialX initialX: CGFloat) -> CGFloat {
        func isAnimatable(withScreenRatio ratio: CGFloat) -> Bool {
            return ratio < 1 && ratio > 0
        }
        
        func alphaForItem(withRatio ratio: CGFloat, offset: CGFloat, base: CGFloat, variable: CGFloat) -> CGFloat {
            // We need to move by the offset in order to use the lineal equation
            return min(base + ((offset + ratio) * variable), 1.0)
        }
        
        let ratio = offsetFactorForItem(withInitialX: initialX)
        let base: CGFloat = 0.7
        let variable = 1 - base
        
        guard isAnimatable(withScreenRatio: ratio) else {
            return base
        }
        
        let leftAlpha = alphaForItem(withRatio: ratio, offset: 0.5, base: base, variable: variable)
        let rightAlpha = alphaForItem(withRatio: ratio, offset: 1.5, base: base, variable: variable)
        
        let alpha = ratio < centerRatio ? leftAlpha : rightAlpha
        return max(base, easeInQuad(alpha))
    }
    
    private func offsetFactorForItem(withInitialX initialX: CGFloat) -> CGFloat {
        let itemAnchor = initialX + cellWidth / 2
        let draggedAnchor = itemAnchor - (collectionView?.contentOffset.x ?? 0)
        
        return draggedAnchor / visibleWidth
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let anchor: CGFloat = cellWidth + interitemSpacing
        let previousPageOffset: CGFloat = CGFloat(page-1) * (cellWidth + cellLayout.insets.left / 2) + cellLayout.insets.left
        let nextPageOffset: CGFloat = CGFloat(page+1) * (cellWidth + cellLayout.insets.left / 2) + cellLayout.insets.left
        var proposeRealEndPostion: CGFloat = 0
        if velocity.x > 0 {
            proposeRealEndPostion = min(nextPageOffset, proposedContentOffset.x)
        } else {
            proposeRealEndPostion = max(previousPageOffset, proposedContentOffset.x)
        }
        return CGPoint(x: round(proposeRealEndPostion / anchor) * anchor, y: 0)
    }
    
    /* Return all attributes in the cache whose frame intersects with the rect passed to the method */
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesForItem(at: indexPath)
    }
    
    private func attributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        update(attributes: attributes, forItemAt: indexPath)
        return attributes
    }
    
    private func update(attributes: UICollectionViewLayoutAttributes, forItemAt indexPath: IndexPath) {
        attributes.zIndex = indexPath.row
        var frame: CGRect = .zero
        let x = CGFloat(indexPath.row) * (cellWidth + cellLayout.insets.left / 2) + cellLayout.insets.left
        frame = CGRect(x: x, y: yInsetForItem(withInitialX: x), width: cellWidth, height: cellHeight)
        attributes.frame = frame
        attributes.alpha = alphaForItem(withInitialX: x)
    }
    
    //     Return true so that the layout is continuously invalidated as the user scrolls
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
