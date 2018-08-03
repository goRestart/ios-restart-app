//
//  EmptyCellDrawer.swift
//  LetGo
//
//  Created by Dídac on 10/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class EmptyCellDrawer: BaseCollectionCellDrawer<EmptyCell>, GridCellDrawer {
    func willDisplay(_ model: LGEmptyViewModel, inCell cell: EmptyCell) { }

    func draw(_ model: LGEmptyViewModel, style: CellStyle, inCell cell: EmptyCell, isPrivateList: Bool = false) { }
}
