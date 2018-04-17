//
//  WaterFallLayoutHeaderTypes.swift
//  LetGo
//
//  Created by Haiyan Ma on 13/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

/// CollectionView header sticky type during scrolling
///
/// - nonSticky: a normal collectionView header
/// - sticky: the same behaviour as tableView headers. It stays on the top till all cells in its section disappear
/// - pinned: once scrolled to the top of collectionView, it stays on the top even if all cells in its section disappear
enum HeaderStickyType: Int {
    case nonSticky, sticky, pinned
}
