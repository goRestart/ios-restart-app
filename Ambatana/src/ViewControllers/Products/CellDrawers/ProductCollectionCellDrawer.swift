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
        switch style {
        case .Small:
            cell.title.font = UIFont.systemBoldFont(size: 20)
        case .Big:
            cell.title.font = UIFont.systemBoldFont(size: 24)
        }
        cell.imageView.image = model.image
        cell.title.text = model.title.uppercase
    }
}
