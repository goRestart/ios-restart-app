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
        guard let selectedItems = indexPathsForSelectedItems() else { return }
        selectedItems.forEach {
            deselectItemAtIndexPath($0, animated: false)
        }
    }
}
