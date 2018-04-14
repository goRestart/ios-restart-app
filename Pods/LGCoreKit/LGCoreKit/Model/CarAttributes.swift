//
//  CarAttributes.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 11/04/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public struct CarAttributes: Equatable, Decodable {
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
    
    
    // MARK: Decodable
    
    public init(from decoder: Decoder) throws {
        let keyedContainerProductsApi = try decoder.container(keyedBy: CodingKeysProductsApi.self)
        let keyedContainerCarsApi = try decoder.container(keyedBy: CodingKeysCarsApi.self)
        
        if let makeIdValue = try keyedContainerProductsApi.decodeIfPresent(String.self, forKey: .make) {
            makeId = makeIdValue
        } else {
            makeId = try keyedContainerCarsApi.decodeIfPresent(String.self, forKey: .makeId)
        }
        make = nil
        if let modelIdValue = try keyedContainerProductsApi.decodeIfPresent(String.self, forKey: .model) {
            modelId = modelIdValue
        } else {
            modelId = try keyedContainerCarsApi.decodeIfPresent(String.self, forKey: .modelId)
        }
        model = nil
        year = try keyedContainerCarsApi.decodeIfPresent(Int.self, forKey: .year)
    }
    
    
    
    enum CodingKeysProductsApi: String, CodingKey {
        case make = "make"
        case model = "model"
        case year = "year"
    }
    enum CodingKeysCarsApi: String, CodingKey {
        case makeId = "makeId"
        case modelId = "modelId"
        case year = "year"
    }
}

public func ==(lhs: CarAttributes, rhs: CarAttributes) -> Bool {
    return lhs.make == rhs.make && lhs.makeId == rhs.makeId &&
        lhs.model == rhs.model && lhs.modelId == rhs.modelId &&
        lhs.year == rhs.year
}

