//
//  ChatCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol ChatCellDrawer: TableCellDrawer {
    func draw(_ cell: UITableViewCell, message: ChatViewMessage)
}
