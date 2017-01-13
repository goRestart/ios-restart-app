//
//  ReportUserCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 05/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

class ReportUserCellDrawer: BaseCollectionCellDrawer<ReportUserCell> {
    func draw(_ collectionCell: UICollectionViewCell, image: UIImage?, text: String, selected: Bool) {
        guard let cell = collectionCell as? ReportUserCell else { return }

        cell.reportIcon.image = image
        cell.reportText.text = text
        cell.reportSelected.isHidden = !selected
    }
}
