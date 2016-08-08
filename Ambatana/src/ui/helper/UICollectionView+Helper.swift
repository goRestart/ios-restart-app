//
//  UICollectionView+Helper.swift
//  LetGo
//
//  Created by Eli Kohen on 07/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import CollectionVariable

extension UICollectionView {
    func deselectAll() {
        guard let selectedItems = indexPathsForSelectedItems() else { return }
        selectedItems.forEach {
            deselectItemAtIndexPath($0, animated: false)
        }
    }

    func handleCollectionChange<T>(change: CollectionChange<T>, completion: ((Bool) -> Void)? = nil) {
        performBatchUpdates({ [weak self] in
            self?.handleChange(change)
        }, completion: completion)
    }

    private func handleChange<T>(change: CollectionChange<T>) {
        switch change {
        case .Remove(let index, _):
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            deleteItemsAtIndexPaths([indexPath])
        case .Insert(let index, _):
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            insertItemsAtIndexPaths([indexPath])
        case .Composite(let changes):
            changes.forEach { [weak self] change in
                self?.handleChange(change)
            }
        }
    }
}
