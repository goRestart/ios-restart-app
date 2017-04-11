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
    public let  makeId: String?
    public let  model: String?
    public let  modelId: String?
    public let  year: Int?
    public init(make: String?, makeId: String?, model: String?, modelId: String?, year: Int?) {
        self.make = make
        self.makeId = makeId
        self.model = model
        
        self.modelId = modelId
        self.year = year
    }
    
    public static func emptyCarAttributes() -> CarAttributes {
        return CarAttributes(make: nil, makeId: nil, model: nil, modelId: nil, year: nil)
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
     
     {
     "make": {
     "id": "4b301c13-9e5f-442a-a63b-affd15f9268e",
     "name": "Audi"
     },
     "model": {
     "id": "3705d6fe-4c63-424a-929c-64c7b715b620",
     "name": "A1"
     },
     "year": 2000
     }
     
     */
    public static func decode(_ j: JSON) -> Decoded<CarAttributes> {
        let init1 = curry(CarAttributes.init)
            <^> j <|? ["make", "id"]
            <*> j <|? ["make", "name"]
        let init2 = init1   <*> j <|? ["model", "id"]
            <*> j <|? ["model", "name"]
            <*> j <|? "year"
        return init2
    }
}
