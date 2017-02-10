//
//  GridCellDrawerFactory.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import UIKit
import LGCoreKit

enum CellStyle {
    case small, big
}

class GridDrawerManager {

    var cellStyle: CellStyle = .small
    var freePostingAllowed: Bool = true
    
    private let productDrawer = ProductCellDrawer()
    private let collectionDrawer = ProductCollectionCellDrawer()
    private let emptyCellDrawer = EmptyCellDrawer()
    private let showFeaturedStripeHelper = ShowFeaturedStripeHelper(featureFlags: FeatureFlags.sharedInstance,
                                                                    myUserRepository: Core.myUserRepository)


    func registerCell(inCollectionView collectionView: UICollectionView) {
        ProductCellDrawer.registerCell(collectionView)
        ProductCollectionCellDrawer.registerCell(collectionView)
        EmptyCellDrawer.registerCell(collectionView)
    }
    
    func cell(_ model: ProductCellModel, collectionView: UICollectionView, atIndexPath: IndexPath) -> UICollectionViewCell {
        switch model {
        case .productCell:
            return productDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .collectionCell:
            return collectionDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .emptyCell:
            return emptyCellDrawer.cell(collectionView, atIndexPath: atIndexPath)
        }
    }
    
    func draw(_ model: ProductCellModel, inCell cell: UICollectionViewCell) {
        switch model {
        case .productCell(let product) where cell is ProductCell:
            guard let cell = cell as? ProductCell else { return }
            let isFeatured = showFeaturedStripeHelper.shouldShowFeaturedStripeFor(product)
            let data = ProductData(productID: product.objectId, thumbUrl: product.thumbnail?.fileURL,
                                   isFree: product.price.free && freePostingAllowed, isFeatured: isFeatured)
            return productDrawer.draw(data, style: cellStyle, inCell: cell)
        case .collectionCell(let style) where cell is CollectionCell:
            guard let cell = cell as? CollectionCell else { return }
            return collectionDrawer.draw(style, style: cellStyle, inCell: cell)
        case .emptyCell(let vm):
            guard let cell = cell as? EmptyCell else { return }
            return emptyCellDrawer.draw(vm, style: cellStyle, inCell: cell)
        default:
            assert(false, "⛔️ You shouldn't be here")
        }
    }
}
