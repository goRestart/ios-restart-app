//
//  BaseNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 20/10/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class BaseNotificationCellDrawer<T: UITableViewCell where T: ReusableCell>: BaseTableCellDrawer<T>, NotificationCellDrawer {

    /**
     Draw the cell, proxy method to `draw(cell: T...)`
     If the cell is not of type T, it will do nothing.
     If the cell is of type T, it will call the real draw method implemented by the subclass

     - parameter cell:     Cell where the notification is going to be draw, must be T
     - parameter data:      data to draw
     */
    func draw(cell: UITableViewCell, data: NotificationData) {
        guard let myCell = cell as? T else { return }
        draw(myCell, data: data)
    }

    /**
     Abstract method that should be implemented by the subclasses.
     */
    func draw(cell: T, data: NotificationData) {}
}
