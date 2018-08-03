//
//  PromoCellDrawer.swift
//  LetGo
//
//  Created by Tomas Cobo on 05/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

class PromoCellDrawer: BaseCollectionCellDrawer<PromoCell>, GridCellDrawer  {
    func willDisplay(_ model: PromoCellData, inCell cell: PromoCell) { }
    
    func draw(_ model: PromoCellData, style: CellStyle, inCell cell: PromoCell, isPrivateList: Bool = false) {
        cell.setup(with: model)
    }
}
