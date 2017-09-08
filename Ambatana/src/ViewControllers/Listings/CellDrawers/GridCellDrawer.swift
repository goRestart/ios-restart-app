//
//  GridCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

protocol GridCellDrawer {
    associatedtype T: UICollectionViewCell
    associatedtype M
    func draw(_ model: M, style: CellStyle, inCell cell: T)
}
