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
        handleChange(change, animation: animation)
        completion?()
    }

    private func handleChange<T>(_ change: CollectionChange<T>, animation: UITableViewRowAnimation) {
        reloadData()
    }
}
