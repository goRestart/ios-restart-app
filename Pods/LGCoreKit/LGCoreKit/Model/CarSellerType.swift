//
//  CarSellerType.swift
//  LGCoreKit
//
//  Created by Tomas Cobo on 11/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public enum CarSellerType {
    case individual, professional
    
    public static var all: [CarSellerType] {
        return [.individual, .professional]
    }
    
    public var indexInAll: Int? {
        return index(in: CarSellerType.all)
    }
}
