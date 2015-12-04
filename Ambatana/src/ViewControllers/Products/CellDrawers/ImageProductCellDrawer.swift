//
//  ImageProductCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

class ImageProductCellDrawer: FullProductCellDrawer {
    override func draw(collectionCell: UICollectionViewCell, data: ProductCellData) {
        super.draw(collectionCell, data: data)

        guard let cell = collectionCell as? ProductCell else { return }

        cell.nameLabel.text = ""
        cell.nameTopConstraint.constant = 2
        cell.priceLabel.text = ""
    }
}