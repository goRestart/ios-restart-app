//
//  GridCellDrawerFactory.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import UIKit

class GridDrawerManager {
    
    var productDrawer = ProductCellDrawer()
    var bannerDrawer = BannerCellDrawer()
    
    func registerCell(inCollectionView collectionView: UICollectionView) {
        ProductCellDrawer.registerCell(collectionView)
        BannerCellDrawer.registerCell(collectionView)
    }
    
    func cell(model: ProductListModel, collectionView: UICollectionView, atIndexPath: NSIndexPath) -> UICollectionViewCell {
        switch model {
        case .Banner:
            return bannerDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .Product:
            return productDrawer.cell(collectionView, atIndexPath: atIndexPath)
        }
    }
    
    func draw(model: ProductListModel, inCell cell: UICollectionViewCell) {
        switch model {
        case .Banner(let data) where cell is ProductCell:
            guard let cell = cell as? ProductCell else { return }
            return bannerDrawer.draw(data, inCell: cell)
        case .Product(let data) where cell is ProductCell:
            guard let cell = cell as? ProductCell else { return }
            return productDrawer.draw(data, inCell: cell)
        default:
            assert(false, "⛔️ You shouldn't be here!")
        }
    }
}
