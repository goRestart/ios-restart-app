//
//  ProductCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

struct ProductCellData {
    var title: String?
    var price: String?
    var thumbUrl: NSURL?
    var status: ProductStatus
    var date: NSDate?
    var isFavorite: Bool
    var cellWidth: CGFloat
    var indexPath: NSIndexPath?
}

protocol ProductCellDrawer: CollectionCellDrawer {
    func draw(collectionCell: UICollectionViewCell, data: ProductCellData, delegate: ProductCellDelegate?)
}
