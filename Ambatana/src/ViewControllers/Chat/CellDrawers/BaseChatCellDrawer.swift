//
//  BaseChatCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 30/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class BaseChatCellDrawer<T: UITableViewCell where T: ReusableCell>: ChatCellDrawer {
    
    /**
    Register the Cell of type T in the given UITableView
    
    - parameter tableView: UITableView where the cell should be registered
    */
    static func registerCell(tableView: UITableView) {
        let myMessageCellNib = UINib(nibName: T.reusableID(), bundle: nil)
        tableView.registerNib(myMessageCellNib, forCellReuseIdentifier: T.reusableID())
    }
    
    /**
    Dequeue a cell for the given tableView using the generic T to get the ID.
    
    - parameter tableView:   UITableView to dequeue the cell from
    - parameter atIndexPath: IndexPath of the cell to be dequeued
    
    - returns: a reused UITableViewCell
    */
    func cell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(T.reusableID(), forIndexPath: atIndexPath)
    }
    
    /**
    Draw the cell, proxy method to `draw(cell: T...)`
    If the cell is not of type T, it will do nothing.
    If the cell is of type T, it will call the real draw method implemented by the subclass
    
    - parameter cell:     Cell where the message is going to be draw, must be T
    - parameter message:  Message to draw
    - parameter avatar:   Avatar to draw if any
    - parameter delegate: Delegate of the cell if any
    */
    func draw(cell: UITableViewCell, message: Message, avatar: File?, delegate: AnyObject?) {
        guard let myCell = cell as? T else { return }
        draw(myCell, message: message, avatar: avatar, delegate: delegate)
    }
    
    /**
    Abstract method that should be implemented by the subclasses.
    */
    func draw(cell: T, message: Message, avatar: File?, delegate: AnyObject?) {}
}
