//
//  UITableView+Changes.swift
//  LetGo
//
//  Created by Eli Kohen on 09/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


import LGCoreKit

extension UITableView {
    func handleCollectionChange<T>(_ change: CollectionChange<T>, animation: UITableViewRowAnimation = .none, completion: (() -> Void)? = nil) {
        beginUpdates()
        handleChange(change, animation: animation)
        endUpdates()
        completion?()
    }

    private func handleChange<T>(_ change: CollectionChange<T>, animation: UITableViewRowAnimation) {
        switch change {
        case let .remove(index, _):
            let indexPath = IndexPath(row: index, section: 0)
            deleteRows(at: [indexPath], with: animation)
        case let .insert(index, _):
            let indexPath = IndexPath(row: index, section: 0)
            insertRows(at: [indexPath], with: animation)
        case let .swap(from, to, _):
            let indexPaths = [IndexPath(row: from, section: 0), IndexPath(row: to, section: 0)]
            reloadRows(at: indexPaths, with: .automatic)
        case let .move(from, to, _):
            let indexPaths = (from...to).map { IndexPath(row: $0, section: 0) }
            reloadRows(at: indexPaths, with: .automatic)
        case .composite(let changes):
            changes.forEach { [weak self] change in
                self?.handleChange(change, animation: animation)
            }
        }
    }
}
