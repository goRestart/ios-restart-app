//
//  ListingDeckCollectionViewLayout.swift
//  LetGo
//
//  Created by Facundo Menzella on 23/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit

typealias EasingFunction = (CGFloat) -> CGFloat

struct ListingDeckCellLayout {
    let insets: UIEdgeInsets
    let anchors: Anchors
    let verticalInsetDelta: CGFloat

    struct Anchors {
        let leftAnchor: CGFloat
        let anchor: CGFloat
        let rightAnchor: CGFloat
    }

}

final class ListingDeckCollectionViewLayout: UICollectionViewFlowLayout {

    let easeInQuad: EasingFunction = { t in return t * t }

    var cache = [UICollectionViewLayoutAttributes]()
    private var shouldInvalidateCache: Bool { return cache.count != numberOfItems }

    private var cellLayout: ListingDeckCellLayout
    var page: Int { return Int(pageOffset(givenOffset: collectionView?.contentOffset.x ?? 0)) }

    let horizontalInset: CGFloat = 32.0
    let verticalInset: CGFloat = 16.0
    var interitemSpacing: CGFloat { get { return cellLayout.insets.left / 2.0 } }
    var leftAnchor: CGFloat { get { return cellLayout.anchors.leftAnchor } }
    var anchor: CGFloat { get { return cellLayout.anchors.anchor } }
    var rightAnchor: CGFloat { get { return cellLayout.anchors.rightAnchor } }

    override var collectionViewContentSize : CGSize {
        let count = CGFloat(numberOfItems)
        let width = count * cellWidth + (count - 1) * horizontalInset/2 + 2*horizontalInset
        return CGSize(width: width, height: cellHeight)
    }

    var visibleWidth: CGFloat { get { return (collectionView?.bounds.width ?? 375) } }
    var visibleHeight: CGFloat { get { return (collectionView?.bounds.height ?? 750) } }

    var cellWidth: CGFloat { get { return visibleWidth - 2*horizontalInset } }
    var cellHeight: CGFloat { get { return visibleHeight - verticalInset } }

    var numberOfItems: Int { get { return collectionView?.numberOfItems(inSection: 0) ?? 0 } }

    convenience init(cellLayout: ListingDeckCellLayout) {
        self.init()
        self.cellLayout = cellLayout
    }

    override init() {
        let insets = UIEdgeInsets(top: 16.0, left: 32.0, bottom: 32.0, right: 32.0)
        let anchors = ListingDeckCellLayout.Anchors(leftAnchor: 0.25, anchor: 0.5, rightAnchor: 0.75)
        self.cellLayout = ListingDeckCellLayout(insets: insets, anchors: anchors, verticalInsetDelta: insets.top)
        super.init()

        self.scrollDirection = .horizontal
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
        let leftInset = min(minimum + ((0.5 - factor) * verticalInset), verticalInset)
        let rightInset = min(minimum + ((factor - 0.5) * verticalInset), verticalInset)
        let inset = factor < anchor ? leftInset : rightInset
        return inset
    }

    private func alphaForItem(withInitialX initialX: CGFloat) -> CGFloat {
        let factor = offsetFactorForItem(withInitialX: initialX)
        let base: CGFloat = 0.7

        guard factor < 1 && factor > 0 else {
            return base
        }

        let variable = 1 - base
        let midAnchor = anchor

        let leftAlpha = min(base + ((0.5 + factor) * variable), 1.0)
        let rightAlpha = min(base + ((1.5 - factor) * variable), 1.0)

        let alpha = factor < midAnchor ? leftAlpha : rightAlpha
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
        return CGPoint(x: round(proposedContentOffset.x / anchor) * anchor, y: 0)
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
        let x = CGFloat(indexPath.row) * (cellWidth + horizontalInset / 2) + horizontalInset
        frame = CGRect(x: x, y: yInsetForItem(withInitialX: x), width: cellWidth, height: cellHeight)
        attributes.frame = frame
        attributes.alpha = alphaForItem(withInitialX: x)
    }



    //     Return true so that the layout is continuously invalidated as the user scrolls
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
