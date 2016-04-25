//
//  IndexHelper.swift
//  LetGo
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

public final class IndexHelper {
    public static func indexesFromIndex(index: Int, count: Int) -> [Int] {
        var indexes: [Int] = []
        for i in index..<index + count {
            indexes.append(i)
        }
        return indexes
    }
}
