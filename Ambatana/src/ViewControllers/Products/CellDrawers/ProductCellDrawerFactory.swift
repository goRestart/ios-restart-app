//
//  ProductCellDrawerFactory.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

public class ProductCellDrawerFactory {

    static func drawerForProductMode(mode: ProductListCellMode) -> ProductCellDrawer {
        switch mode {
        case .FullInfo:
            return FullProductCellDrawer()
        case .JustImage:
            return ImageProductCellDrawer()
        }
    }

    static func registerCells(collectionView: UICollectionView) {
        FullProductCellDrawer.registerCell(collectionView)
        ImageProductCellDrawer.registerCell(collectionView)
    }
}