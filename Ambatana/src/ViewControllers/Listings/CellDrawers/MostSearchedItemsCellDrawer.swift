//
//  MostSearchedItemsCellDrawer.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 23/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

class MostSearchedItemsCellDrawer: BaseCollectionCellDrawer<MostSearchedItemsListingListCell>, GridCellDrawer  {
    func willDisplay(_ model: MostSearchedItemsCardData, inCell cell: MostSearchedItemsListingListCell) { }
    
    func draw(_ model: MostSearchedItemsCardData, style: CellStyle, inCell cell: MostSearchedItemsListingListCell) {
        cell.setupWith(data: model)
    }
}
