//
//  UITableView+Changes.swift
//  LetGo
//
//  Created by Eli Kohen on 09/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import CollectionVariable

extension UITableView {
    func handleCollectionChange<T>(change: CollectionChange<T>, animation: UITableViewRowAnimation = .None, completion: (() -> Void)? = nil) {
        beginUpdates()
        handleChange(change, animation: animation)
        endUpdates()
        completion?()
    }

    private func handleChange<T>(change: CollectionChange<T>, animation: UITableViewRowAnimation) {
        switch change {
        case .Remove(let index, _):
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            deleteRowsAtIndexPaths([indexPath], withRowAnimation: animation)
        case .Insert(let index, _):
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            insertRowsAtIndexPaths([indexPath], withRowAnimation: animation)
        case .Composite(let changes):
            changes.forEach { [weak self] change in
                self?.handleChange(change, animation: animation)
            }
        }
    }
}
