//
//  CellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

protocol TableCellDrawer {
    func cell(_ tableView: UITableView, atIndexPath: IndexPath) -> UITableViewCell
    static func registerCell(_ tableView: UITableView)
    static func registerClassCell(_ tableView: UITableView)
}

protocol CollectionCellDrawer {
    func cell(_ collectionView: UICollectionView, atIndexPath: IndexPath) -> UICollectionViewCell
    static func registerCell(_ collectionView: UICollectionView)
}
