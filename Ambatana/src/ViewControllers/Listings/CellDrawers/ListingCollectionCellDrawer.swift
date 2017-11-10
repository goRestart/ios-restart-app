//
//  ListingCollectionCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 16/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class ListingCollectionCellDrawer: BaseCollectionCellDrawer<CollectionCell>, GridCellDrawer {
    func willDisplay(_ model: CollectionCellType, inCell cell: CollectionCell) { }

    func draw(_ model: CollectionCellType, style: CellStyle, inCell cell: CollectionCell) {
        cell.layoutIfNeeded()
        cell.imageView.image = model.image
        cell.title.text = model.title.localizedUppercase
        cell.title.font = UIFont.systemBoldFont(size: cell.title.fontSizeAdjusted())
    }
}
