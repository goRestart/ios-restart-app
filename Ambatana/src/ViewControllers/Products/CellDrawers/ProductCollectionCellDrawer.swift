//
//  CollectionCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 16/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class ProductCollectionCellDrawer: BaseCollectionCellDrawer<CollectionCell>, GridCellDrawer {
    func draw(model: CollectionCellType, style: CellStyle, inCell cell: CollectionCell) {
        cell.layoutIfNeeded()
        cell.imageView.image = model.image
        cell.title.text = model.title.uppercase
        cell.title.font = UIFont.systemBoldFont(size: cell.title.fontSizeAdjusted())
    }
}
