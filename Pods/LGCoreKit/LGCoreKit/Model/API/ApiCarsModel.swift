//
//  ApiCarsModel.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

struct ApiCarsModel: CarsModel, Decodable {
    var modelId: String
    var modelName: String
    
    // MARK: Decodable
    
    /*
     {
     "id": "b243756c-456b-4132-8a6f-c63758551f77",  // uuid4
     "name": "A3", // string
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        modelId = try keyedContainer.decode(String.self, forKey: .id)
        modelName = try keyedContainer.decode(String.self, forKey: .name)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
