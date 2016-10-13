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
    case Small, Big
}

class GridDrawerManager {

    var cellStyle: CellStyle = .Small

    private let productDrawer = ProductCellDrawer()
    private let collectionDrawer = ProductCollectionCellDrawer();
    
    func registerCell(inCollectionView collectionView: UICollectionView) {
        ProductCellDrawer.registerCell(collectionView)
        ProductCollectionCellDrawer.registerCell(collectionView)
    }
    
    func cell(model: ProductCellModel, collectionView: UICollectionView, atIndexPath: NSIndexPath) -> UICollectionViewCell {
        switch model {
        case .ProductCell:
            return productDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .CollectionCell:
            return collectionDrawer.cell(collectionView, atIndexPath: atIndexPath)
        }
    }
    
    func draw(model: ProductCellModel, inCell cell: UICollectionViewCell) {
        switch model {
        case .ProductCell(let product) where cell is ProductCell:
            guard let cell = cell as? ProductCell else { return }
            return productDrawer.draw(product.cellData, style: cellStyle, inCell: cell)

        case .CollectionCell(let style) where cell is CollectionCell:
            guard let cell = cell as? CollectionCell else { return }
            return collectionDrawer.draw(style, style: cellStyle, inCell: cell)
        
        default:
            assert(false, "⛔️ You shouldn't be here")
        }
    }
}


private extension Product {
    var cellData: ProductData {
        return ProductData(productID: objectId, thumbUrl: thumbnail?.fileURL, isFree: price.free)
    }
}
