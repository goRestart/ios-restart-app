//
//  ProductCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

protocol ProductCellDrawer: CollectionCellDrawer {
    func draw(collectionCell: UICollectionViewCell, data: ProductCellData)
}
