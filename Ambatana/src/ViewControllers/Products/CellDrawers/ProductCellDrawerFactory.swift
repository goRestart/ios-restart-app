//
//  ProductCellDrawerFactory.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

public class ProductCellDrawerFactory {

    static func drawerForProduct(withActions: Bool) -> ProductCellDrawer {
        return ImageProductCellDrawer(showActions: withActions)
    }

    static func registerCells(collectionView: UICollectionView) {
        ImageProductCellDrawer.registerCell(collectionView)
    }
}