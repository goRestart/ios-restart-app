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
        //TODO: DISABLED DUE TO PRODUCT RESTRICTIONS FOR VERSION 1.5.5
//        if withActions {
//            return ActionsProductCellDrawer()
//        } else {
            return ImageProductCellDrawer()
//        }
    }

    static func registerCells(collectionView: UICollectionView) {
        ImageProductCellDrawer.registerCell(collectionView)
    }
}