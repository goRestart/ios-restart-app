//
//  BaseCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

class BaseTableCellDrawer<T: UITableViewCell>: TableCellDrawer where T: ReusableCell {

    /**
    Register the Cell of type T in the given UITableView

    - parameter tableView: UITableView where the cell should be registered
    */
    static func registerCell(_ tableView: UITableView) {
        let cellNib = UINib(nibName: T.reusableID, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: T.reusableID)
    }

    static func registerClassCell(_ tableView: UITableView) {
        tableView.register(T.self, forCellReuseIdentifier: T.reusableID)
    }
    
    /**
    Dequeue a cell for the given tableView using the generic T to get the ID.

    - parameter tableView:   UITableView to dequeue the cell from
    - parameter atIndexPath: IndexPath of the cell to be dequeued

    - returns: a reused UITableViewCell
    */
    func cell(_ tableView: UITableView, atIndexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: T.reusableID, for: atIndexPath)
    }
}

class BaseCollectionCellDrawer<T: UICollectionViewCell>: CollectionCellDrawer where T: ReusableCell {

    /**
    Register the Cell of type T in the given UICollectionView

    - parameter collectionView: UICollectionView where the cell should be registered
    */
    static func registerCell(_ collectionView: UICollectionView) {
        let cellNib = UINib(nibName: T.reusableID, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: T.reusableID)
    }

    /**
    Dequeue a cell for the given UICollectionView using the generic T to get the ID.

    - parameter collectionView:   UICollectionView to dequeue the cell from
    - parameter atIndexPath: IndexPath of the cell to be dequeued

    - returns: a reused UITableViewCell
    */
    func cell(_ collectionView: UICollectionView, atIndexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: T.reusableID, for: atIndexPath)
    }
}
