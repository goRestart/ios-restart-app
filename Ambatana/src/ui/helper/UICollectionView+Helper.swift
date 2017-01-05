//
//  UICollectionView+Helper.swift
//  LetGo
//
//  Created by Eli Kohen on 07/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension UICollectionView {
    func deselectAll() {
        guard let selectedItems = indexPathsForSelectedItems else { return }
        selectedItems.forEach {
            deselectItem(at: $0, animated: false)
        }
    }

    func handleCollectionChange<T>(_ change: CollectionChange<T>, completion: ((Bool) -> Void)? = nil) {
        performBatchUpdates({ [weak self] in
            self?.handleChange(change)
        }, completion: completion)
    }

    private func handleChange<T>(_ change: CollectionChange<T>) {
        switch change {
        case .remove(let index, _):
            let indexPath = IndexPath(forRow: index, inSection: 0)
            deleteItemsAtIndexPaths([indexPath])
        case .insert(let index, _):
            let indexPath = IndexPath(forRow: index, inSection: 0)
            insertItemsAtIndexPaths([indexPath])
        case .composite(let changes):
            changes.forEach { [weak self] change in
                self?.handleChange(change)
            }
        }
    }
}
