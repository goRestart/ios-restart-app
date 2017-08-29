//
//  AnimatedPageCollectionViewLayout.swift
//  LetGo
//
// Based on: https://github.com/KelvinJin/AnimatedCollectionViewLayout
//

import Foundation
import UIKit


/// A `UICollectionViewFlowLayout` subclass enables custom transitions between cells.
public class AnimatedPageCollectionViewLayout: UICollectionViewFlowLayout {

    /// The animator that would actually handle the transitions.
    public var animator: PageAttributesAnimator?

    /// Overrided so that we can store extra information in the layout attributes.
    public override class var layoutAttributesClass: AnyClass { return AnimatedPageCollectionViewLayoutAttributes.self }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        return attributes.flatMap { $0.copy() as? AnimatedPageCollectionViewLayoutAttributes }.map { self.transformLayoutAttributes($0) }
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // We have to return true here so that the layout attributes would be recalculated
        // everytime we scroll the collection view.
        return true
    }

    private func transformLayoutAttributes(_ attributes: AnimatedPageCollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {

        guard let collectionView = self.collectionView else { return attributes }

        let newAttributes = attributes

        /**
         The position for each cell is defined as the ratio of the distance between
         the center of the cell and the center of the collectionView and the collectionView width/height
         depending on the scroll direction. It can be negative if the cell is, for instance,
         on the left of the screen if you're scrolling horizontally.
         */

        let distance: CGFloat
        let itemOffset: CGFloat

        if scrollDirection == .horizontal {
            distance = collectionView.frame.width
            itemOffset = newAttributes.center.x - collectionView.contentOffset.x
            newAttributes.startOffset = (newAttributes.frame.origin.x - collectionView.contentOffset.x) / newAttributes.frame.width
            newAttributes.endOffset = (newAttributes.frame.origin.x - collectionView.contentOffset.x - collectionView.frame.width) / newAttributes.frame.width
        } else {
            distance = collectionView.frame.height
            itemOffset = newAttributes.center.y - collectionView.contentOffset.y
            newAttributes.startOffset = (newAttributes.frame.origin.y - collectionView.contentOffset.y) / newAttributes.frame.height
            newAttributes.endOffset = (newAttributes.frame.origin.y - collectionView.contentOffset.y - collectionView.frame.height) / newAttributes.frame.height
        }

        newAttributes.scrollDirection = scrollDirection
        newAttributes.middleOffset = itemOffset / distance - 0.5

        // Cache the contentView since we're going to use it a lot.
        if newAttributes.contentView == nil,
            let cellContentView = collectionView.cellForItem(at: attributes.indexPath)?.contentView {
            newAttributes.contentView = cellContentView
        }

        animator?.animate(collectionView: collectionView, attributes: newAttributes)

        return newAttributes
    }
}

/// A custom layout attributes that contains extra information.
public class AnimatedPageCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    public var contentView: UIView?
    public var scrollDirection: UICollectionViewScrollDirection = .vertical

    /// The ratio of the distance between the start of the cell and the start of the collectionView and the height/width of the cell depending on the scrollDirection. It's 0 when the start of the cell aligns the start of the collectionView. It gets positive when the cell moves towards the scrolling direction (right/down) while getting negative when moves opposite.
    public var startOffset: CGFloat = 0

    /// The ratio of the distance between the center of the cell and the center of the collectionView and the height/width of the cell depending on the scrollDirection. It's 0 when the center of the cell aligns the center of the collectionView. It gets positive when the cell moves towards the scrolling direction (right/down) while getting negative when moves opposite.
    public var middleOffset: CGFloat = 0

    /// The ratio of the distance between the **start** of the cell and the end of the collectionView and the height/width of the cell depending on the scrollDirection. It's 0 when the **start** of the cell aligns the end of the collectionView. It gets positive when the cell moves towards the scrolling direction (right/down) while getting negative when moves opposite.
    public var endOffset: CGFloat = 0

    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone)
        guard let animatedPageCopy = copy as? AnimatedPageCollectionViewLayoutAttributes else { return copy }
        animatedPageCopy.contentView = contentView
        animatedPageCopy.scrollDirection = scrollDirection
        animatedPageCopy.startOffset = startOffset
        animatedPageCopy.middleOffset = middleOffset
        animatedPageCopy.endOffset = endOffset
        return animatedPageCopy
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let o = object as? AnimatedPageCollectionViewLayoutAttributes else { return false }

        return super.isEqual(o)
            && o.contentView == contentView
            && o.scrollDirection == scrollDirection
            && o.startOffset == startOffset
            && o.middleOffset == middleOffset
            && o.endOffset == endOffset
    }
}

/// An animator that _pushes_ the current cell into the screen while the next cell slide in.
public struct PageAttributesAnimator {
    /// The max scale that would be applied to the current cell. 0 means no scale. 0.2 by default.
    public var scaleRate: CGFloat

    public init(scaleRate: CGFloat = 0.2) {
        self.scaleRate = scaleRate
    }

    public func animate(collectionView: UICollectionView, attributes: AnimatedPageCollectionViewLayoutAttributes) {
        let position = attributes.middleOffset
        let contentOffset = collectionView.contentOffset
        let itemOrigin = attributes.frame.origin
        let scaleFactor = scaleRate * min(position, 0) + 1.0
        var transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)

        if attributes.scrollDirection == .horizontal {
            transform = transform.concatenating(CGAffineTransform(translationX: position < 0 ? contentOffset.x - itemOrigin.x : 0, y: 0))
        } else {
            transform = transform.concatenating(CGAffineTransform(translationX: 0, y: position < 0 ? contentOffset.y - itemOrigin.y : 0))
        }

        attributes.transform = transform
        attributes.zIndex = attributes.indexPath.row
    }
}
