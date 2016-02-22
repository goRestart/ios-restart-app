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
        return ImageProductCellDrawer()
        
        // TODO: Just in case we want to show the cell actions again
//        if !withActions {
//            return ImageProductCellDrawer()
//        } else {
//            return ActionsProductCellDrawer()
//        }
    }

    static func registerCells(collectionView: UICollectionView) {
        ImageProductCellDrawer.registerCell(collectionView)
    }
}