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

    func draw(_ model: CollectionCellType, style: CellStyle, inCell cell: CollectionCell, isPrivateList: Bool = false) {
        cell.layoutIfNeeded()
        cell.configure(with: model.image,
                       titleText: model.title.localizedUppercase)
    }
}
