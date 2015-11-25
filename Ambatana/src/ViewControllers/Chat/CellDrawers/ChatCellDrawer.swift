//
//  ChatCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

public protocol ChatCellDrawer {
    func cell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell
    func draw(cell: UITableViewCell, message: Message, avatar: File?, delegate: AnyObject?)
}