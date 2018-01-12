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
    let verticalInsetDelta: CGFloat
}

final class ListingDeckCollectionViewLayout: UICollectionViewFlowLayout {
    private struct Constants {
        static let minAlpha: CGFloat = 0.7
    }
    private struct Defaults {
        static let itemsCount = 0
        static let offset: CGFloat = 0
        static let visibleWidth: CGFloat = 375.0
        static let visibleHeight: CGFloat = 750.0
    }

    private let easeInQuad: EasingFunction = { t in return t * t }

    private var cache = [UICollectionViewLayoutAttributes]()
    private var shouldInvalidateCache: Bool { return cache.count != itemsCount }
    private let cellLayout: ListingDeckCellLayout

    private let centerRatio: CGFloat = 0.5
    private var itemsCount: Int { get { return collectionView?.numberOfItems(inSection: 0) ?? Defaults.itemsCount } }

    var page: Int { return Int(pageOffset(givenOffset: collectionView?.contentOffset.x ?? Defaults.offset)) }
    var interitemSpacing: CGFloat { get { return cellLayout.insets.left / 2.0 } }
    var visibleWidth: CGFloat { get { return (collectionView?.bounds.width ?? Defaults.visibleWidth) } }
    var visibleHeight: CGFloat { get { return (collectionView?.bounds.height ?? Defaults.visibleHeight) } }

    var cellWidth: CGFloat { get { return visibleWidth - 2*cellLayout.insets.left } }
    var cellHeight: CGFloat { get { return visibleHeight - cellLayout.insets.top } }

    override var collectionViewContentSize : CGSize {
        let count = CGFloat(itemsCount)
        let width = count * cellWidth + (count - 1) * cellLayout.insets.left/2 + 2*cellLayout.insets.left
        return CGSize(width: width, height: cellHeight)
    }

    private init(cellLayout: ListingDeckCellLayout) {
        self.cellLayout = cellLayout
        super.init()
        self.scrollDirection = .horizontal
    }

    convenience override init() {
        let doubleMargin = 2*Metrics.margin
        let insets = UIEdgeInsets(top: Metrics.margin, left: doubleMargin, bottom: doubleMargin, right: doubleMargin)
        self.init(cellLayout: ListingDeckCellLayout(insets: insets, verticalInsetDelta: insets.top))
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepare() {
        super.prepare()
        if shouldInvalidateCache {
            cache.removeAll(keepingCapacity: false)
            for item in 0..<itemsCount {
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
        let variable = 1 - Constants.minAlpha

        guard isAnimatable(withScreenRatio: ratio) else {
            return Constants.minAlpha
        }

        let leftAlpha = alphaForItem(withRatio: ratio, offset: 0.5, base: Constants.minAlpha, variable: variable)
        let rightAlpha = alphaForItem(withRatio: -ratio, offset: 1.5, base: Constants.minAlpha, variable: variable)

        let alpha = ratio < centerRatio ? leftAlpha : rightAlpha
        return max(Constants.minAlpha, easeInQuad(alpha))
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
        let x = CGFloat(indexPath.row) * (cellWidth + cellLayout.insets.left / 2) + cellLayout.insets.left
        let yOffset = yInsetForItem(withInitialX: x)
        frame = CGRect(x: x, y: yOffset, width: cellWidth, height: cellHeight - 2*yOffset)
        attributes.frame = frame
        attributes.alpha = alphaForItem(withInitialX: x)
    }

    //     Return true so that the layout is continuously invalidated as the user scrolls
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
