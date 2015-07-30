//
//  IndexPathHelper.swift
//  LetGo
//
//  Created by AHL on 9/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

public final class IndexPathHelper {
    public static func indexPathsFromIndex(index: Int, count: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        for i in index..<index + count {
            indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
        }
        return indexPaths
    }
}
