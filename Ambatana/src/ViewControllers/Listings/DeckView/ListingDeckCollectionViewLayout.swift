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

enum ScrollingDirection {
    case right, none, left
    var delta: Int {
        switch self {
        case .right: return 1
        case .left: return -1
        case .none: return 0
        }
    }

    static func make(velocity: CGFloat) -> ScrollingDirection {
        guard velocity != 0 else { return .none }
        return (velocity < 0) ? .left : .right
    }
}

protocol ListingDeckCollectionViewLayoutDelegate: NSObjectProtocol {
    func targetPage(forProposedPage proposedPage: Int, withScrollingDirection direction: ScrollingDirection) -> Int
}

final class ListingDeckCollectionViewLayout: UICollectionViewFlowLayout {
     private struct Constants {
        static let minAlpha: CGFloat = 0.7
     }
    private struct Defaults {
        static let itemsCount = 1
        static let offset: CGFloat = 0
        static let visibleWidth: CGFloat = 375.0
        static let visibleHeight: CGFloat = 750.0
    }

    private let easeInQuad: EasingFunction = { t in return t * t }

    private var cache = [UICollectionViewLayoutAttributes]()
    private var shouldInvalidateCache: Bool { return cache.count != itemsCount }
    private let cellLayout: ListingDeckCellLayout

    private let centerRatio: CGFloat = 0.5
    private var itemsCount: Int { return collectionView?.numberOfItems(inSection: 0) ?? Defaults.itemsCount }

    var page: Int { return Int(normalizedPageOffset(givenOffset: collectionView?.contentOffset.x ?? Defaults.offset)) }
    var interitemSpacing: CGFloat { return cellLayout.insets.left / 2.0 }
    var visibleWidth: CGFloat {
        get {
            guard let view = collectionView, view.bounds.size != .zero else { return Defaults.visibleWidth }
            return view.bounds.width
        }
    }
    var visibleHeight: CGFloat {
        get {
            guard let view = collectionView, view.bounds.size != .zero else { return Defaults.visibleHeight }
            return view.bounds.height
        }
    }

    var cardSize: CGSize { return CGSize(width: cellWidth, height: cellHeight) }
    var cellWidth: CGFloat { return visibleWidth - 2*cellLayout.insets.left }
    var cellHeight: CGFloat { return visibleHeight }
    var cardInsets: UIEdgeInsets { return cellLayout.insets }
    weak var delegate: ListingDeckCollectionViewLayoutDelegate?

    override var collectionViewContentSize : CGSize {
        let count = CGFloat(itemsCount)
        let width = count * cellWidth + (count - 1) * cellLayout.insets.left/2 + 2*cellLayout.insets.left
        return CGSize(width: width, height: cellHeight)
    }

    private init(cellLayout: ListingDeckCellLayout) {
        self.cellLayout = cellLayout
        super.init()
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0.0
        self.minimumInteritemSpacing = 0.0
        self.sectionInset = .zero;
        self.footerReferenceSize = .zero
        self.headerReferenceSize = .zero
    }

    convenience override init() {
        let doubleMargin = 2*Metrics.shortMargin 
        let insets = UIEdgeInsets(top: Metrics.margin, left: doubleMargin , bottom: doubleMargin, right: doubleMargin)
        self.init(cellLayout: ListingDeckCellLayout(insets: insets, verticalInsetDelta: insets.top))
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepare() {
        super.prepare()
        itemSize = CGSize(width: cellWidth, height: cellHeight)

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

    // Method that indicates how far a page is from the anchor of the collectionView
    func normalizedPageOffset(givenOffset x: CGFloat) -> CGFloat {
        let offset: CGFloat = x
        let pageWidth: CGFloat = cellWidth + interitemSpacing
        let finalOffset = offset + pageWidth/2.0 // because of the first page initial position

        return CGFloat(finalOffset / pageWidth)
    }

    // Method that returns the anchor offset for a given page
    func anchorOffsetForPage(_ page: Int) -> CGPoint {
        let target = CGFloat(page) * (cellWidth + cellLayout.insets.left / 2)
        return CGPoint(x: target, y: 0)
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
        let scrollingDirection = ScrollingDirection.make(velocity: velocity.x)
        let proposedPage = Int(normalizedPageOffset(givenOffset: proposedContentOffset.x))

        if let target = delegate?.targetPage(forProposedPage: proposedPage,
                                             withScrollingDirection: scrollingDirection) {
            return anchorOffsetForPage(target)
        } else {
            let anchor: CGFloat = cellWidth + interitemSpacing
            return CGPoint(x: round(proposedContentOffset.x / anchor) * anchor, y: 0)
        }
    }

    /* Return all attributes in the cache whose frame intersects with the rect passed to the method */
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.row < cache.count && indexPath.row >= 0 else {
            return attributesForItem(at: indexPath)
        }
        return cache[indexPath.row]
    }

    private func attributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        update(attributes: attributes, forItemAt: indexPath)
        return attributes
    }

    private func update(attributes: UICollectionViewLayoutAttributes, forItemAt indexPath: IndexPath) {
        attributes.zIndex = indexPath.row
        let x = CGFloat(indexPath.row) * (cellWidth + cellLayout.insets.left / 2) + cellLayout.insets.left
        let yOffset = yInsetForItem(withInitialX: x)
        attributes.frame = CGRect(x: x, y: yOffset, width: cellWidth, height: cellHeight)
        attributes.alpha = alphaForItem(withInitialX: x)

        let scale = (cellHeight - 2*yOffset) / cellHeight
        attributes.transform = CGAffineTransform.identity.scaledBy(x: 1, y: scale).translatedBy(x: 0, y: -yOffset)
    }

    //     Return true so that the layout is continuously invalidated as the user scrolls
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
