//
//  MockProduct+MockFactory.swift
//  letgoTests
//
//  Created by Facundo Menzella on 04/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

extension MockProduct {
    static func makeProductMocks(_ count: Int, allowDiscarded: Bool) -> [MockProduct] {
        guard !allowDiscarded else {
            return MockProduct.makeMocks(count: count)
        }
        var result: [MockProduct] = []
        repeat {
            result.append(contentsOf: MockProduct.makeMocks(count: count).filter { !$0.status.isDiscarded })
        } while result.count <= count
        return Array(result[0...count-1])
    }
}
