//
//  CarAttributes.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 11/04/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public struct CarAttributes: Equatable {
    public let make: String?
    public let makeId: String?
    public let model: String?
    public let modelId: String?
    public let year: Int?
    
    public static let emptyMake = LGCoreKitConstants.carsMakeEmptyValue
    public static let emptyModel = LGCoreKitConstants.carsModelEmptyValue
    public static let emptyYear = LGCoreKitConstants.carsYearEmptyValue
    
    public var isMakeEmpty: Bool {
        if let make = make {
            return make == CarAttributes.emptyMake
        }
        return true
    }
    
    public var isModelEmpty: Bool {
        if let model = model {
            return model == CarAttributes.emptyModel
        }
        return true
    }
    
    public var isYearEmpty: Bool {
        if let year = year {
            return year == CarAttributes.emptyYear
        }
        return true
    }
    
    static func initWith(makeId: String?, modelId: String?, year: Int?) -> CarAttributes {
        return self.init(makeId: makeId, make: nil, modelId: modelId, model: nil, year: year)
    }
    
    public init(makeId: String?, make: String?, modelId: String?, model: String?, year: Int?) {
        self.makeId = makeId
        self.make = make
        self.modelId = modelId
        self.model = model
        self.year = year
    }
    
    public static func emptyCarAttributes() -> CarAttributes {
        return CarAttributes(makeId: LGCoreKitConstants.carsMakeEmptyValue,
                             make: LGCoreKitConstants.carsMakeEmptyValue,
                             modelId: LGCoreKitConstants.carsModelEmptyValue,
                             model: LGCoreKitConstants.carsModelEmptyValue,
                             year: LGCoreKitConstants.carsYearEmptyValue)
    }
    
    public func updating(makeId: String? = nil,
                         make: String? = nil,
                         modelId: String? = nil,
                         model: String? = nil,
                         year: Int? = nil) -> CarAttributes {
        
        return CarAttributes(makeId: makeId ?? self.makeId,
                             make: make ?? self.make,
                             modelId: modelId ?? self.modelId,
                             model: model ?? self.model,
                             year: year ?? self.year)
    }
}

public func ==(lhs: CarAttributes, rhs: CarAttributes) -> Bool {
    return lhs.make == rhs.make && lhs.makeId == rhs.makeId &&
        lhs.model == rhs.model && lhs.modelId == rhs.modelId &&
        lhs.year == rhs.year
}

extension CarAttributes : Decodable {
    
    /**
     Expects a json in the form:
     
     "attributes": {
        "make": "f762a529-6e99-4244-9568-e31b6705edb5", //required, valid uuid4 or empty string.
        "model": "b243756c-456b-4132-8a6f-c63758551f7", //required, valid uuid4 or empty string.
        "year": 2000 //required, valid year (>1900) or 0.
     
     }
     
     */
    public static func decode(_ j: JSON) -> Decoded<CarAttributes> {
        let init1 = curry(CarAttributes.initWith)
            <^> j <|? "make"
            <*> j <|? "model"
            <*> j <|? "year"
        return init1
    }
}
