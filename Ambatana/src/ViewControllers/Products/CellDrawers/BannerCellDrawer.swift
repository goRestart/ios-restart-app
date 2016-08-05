//
//  BannerCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 5/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class BannerCellDrawer: BaseCollectionCellDrawer<BannerCell>, GridCellDrawer {
    func draw(model: BannerData, style: CellStyle, inCell cell: BannerCell) {
        switch style {
        case .Small:
            cell.title.font = UIFont.systemBoldFont(size: 17)
        case .Big:
            cell.title.font = UIFont.systemBoldFont(size: 19)
        }
        cell.imageView.image = model.style.image
        cell.colorView.backgroundColor = model.style.backColor
        cell.title.text = model.title
    }
}
