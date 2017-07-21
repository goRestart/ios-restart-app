//
//  Listing+MockFactory.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/06/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

extension Listing: MockFactory {
    public static func makeMock() -> Listing {
        switch Int.makeRandom(min: 0, max: 1) {
        case 0:
            return .product(MockProduct.makeMock())
        case 1:
            return .car(MockCar.makeMock())
        default:
            return .car(MockCar.makeMock())
        }
    }
}
