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
    var isMine: Bool
    var cellWidth: CGFloat
    var indexPath: NSIndexPath?
}

protocol ProductCellDrawer: CollectionCellDrawer {
    func cellHeightForThumbnailHeight(height: CGFloat) -> CGFloat
    func draw(collectionCell: UICollectionViewCell, data: ProductCellData)
    func draw(collectionCell: UICollectionViewCell, data: ProductCellData, delegate: ProductCellDelegate?)
}
