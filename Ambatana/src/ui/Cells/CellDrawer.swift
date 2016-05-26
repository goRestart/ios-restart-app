//
//  CellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

protocol TableCellDrawer {
    func cell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell
    static func registerCell(tableView: UITableView)
    static func registerClassCell(tableView: UITableView)
}

protocol CollectionCellDrawer {
    func cell(collectionView: UICollectionView, atIndexPath: NSIndexPath) -> UICollectionViewCell
    static func registerCell(collectionView: UICollectionView)
}