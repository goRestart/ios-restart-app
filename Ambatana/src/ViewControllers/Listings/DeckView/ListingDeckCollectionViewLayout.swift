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

final class ListingDeckCollectionViewLayout: UICollectionViewFlowLayout {

    let easeInQuad: EasingFunction = { t in return t * t }
    var cache = [UICollectionViewLayoutAttributes]()

    let horizontalInset: CGFloat = 32.0
    let verticalInset: CGFloat = 32.0

    override var collectionViewContentSize : CGSize {
        let count = CGFloat(numberOfItems)
        let width = count * cellWidth + (count - 1) * horizontalInset/2 + 2*horizontalInset
        return CGSize(width: width, height: cellHeight)
    }

    var visibleWidth: CGFloat { get { return (collectionView?.bounds.width ?? 375) } }

    let minimumAnchor: CGFloat = 0.25
    let leftAnchor: CGFloat = 0.4
    let anchor: CGFloat = 0.5
    let rightAnchor: CGFloat = 0.75
    let maximumAnchor: CGFloat = 0.7

    var cellWidth: CGFloat { get { return visibleWidth - 2*horizontalInset } }
    var cellHeight: CGFloat { get { return (collectionView?.bounds.height)! - verticalInset } }
    var numberOfItems: Int {
        get { return collectionView?.numberOfItems(inSection: 0) ?? 0 }
    }

    override init() {
        super.init()
        self.scrollDirection = .horizontal
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()
        cache.removeAll(keepingCapacity: false)

        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

            attributes.zIndex = item
            var frame: CGRect = .zero
            let x = CGFloat(item) * (cellWidth + horizontalInset / 2) + horizontalInset

            frame = CGRect(x: x, y: yInsetForItem(atIndexPath: indexPath, withInitialX: x), width: cellWidth, height: cellHeight)

            attributes.frame = frame
            attributes.alpha = alphaForItem(atIndexPath: indexPath, withInitialX: x)
            cache.append(attributes)
        }
    }

    private func yInsetForItem(atIndexPath indexPath: IndexPath, withInitialX initialX: CGFloat) -> CGFloat {
        let factor = offsetFactorForItem(withInitialX: initialX)

        guard factor < 1 && factor > 0 else {
            return verticalInset
        }

        let minimumInset = verticalInset / 2.0
        let leftInset = min(minimumInset + ((0.5 - factor) * verticalInset), verticalInset)
        let rightInset = min(minimumInset + ((factor - 0.5) * verticalInset), verticalInset)
        let inset = factor < anchor ? leftInset : rightInset

        return inset
    }

    private func alphaForItem(atIndexPath indexPath: IndexPath, withInitialX initialX: CGFloat) -> CGFloat {
        let factor = offsetFactorForItem(withInitialX: initialX)
        let midAnchor = anchor

        let leftAlpha = factor / 0.5
        let rightAlpha = (1.5 - factor) / 0.5

        guard factor < 1 && factor > 0 else {
            return 0.7
        }

        let alpha = factor < midAnchor ? min(max(0.7, leftAlpha), 1) : min(max(0.7, rightAlpha), 1)
        return max(0.7, easeInQuad(alpha))
    }

    private func offsetFactorForItem(withInitialX initialX: CGFloat) -> CGFloat {
        let itemAnchor = initialX + cellWidth / 2
        let draggedAnchor = itemAnchor - (collectionView?.contentOffset.x ?? 0)

        return draggedAnchor / visibleWidth
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

    /* Return true so that the layout is continuously invalidated as the user scrolls */
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
