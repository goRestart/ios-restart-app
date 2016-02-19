//
//  BaseCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

class BaseTableCellDrawer<T: UITableViewCell where T: ReusableCell>: TableCellDrawer {

    /**
    Register the Cell of type T in the given UITableView

    - parameter tableView: UITableView where the cell should be registered
    */
    static func registerCell(tableView: UITableView) {
        let cellNib = UINib(nibName: T.reusableID, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: T.reusableID)
    }

    /**
    Dequeue a cell for the given tableView using the generic T to get the ID.

    - parameter tableView:   UITableView to dequeue the cell from
    - parameter atIndexPath: IndexPath of the cell to be dequeued

    - returns: a reused UITableViewCell
    */
    func cell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(T.reusableID, forIndexPath: atIndexPath)
    }
}

class BaseCollectionCellDrawer<T: UICollectionViewCell where T: ReusableCell>: CollectionCellDrawer {

    /**
    Register the Cell of type T in the given UICollectionView

    - parameter collectionView: UICollectionView where the cell should be registered
    */
    static func registerCell(collectionView: UICollectionView) {
        let cellNib = UINib(nibName: T.reusableID, bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: T.reusableID)
    }

    /**
    Dequeue a cell for the given UICollectionView using the generic T to get the ID.

    - parameter collectionView:   UICollectionView to dequeue the cell from
    - parameter atIndexPath: IndexPath of the cell to be dequeued

    - returns: a reused UITableViewCell
    */
    func cell(collectionView: UICollectionView, atIndexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(T.reusableID, forIndexPath: atIndexPath)
    }
    
}

