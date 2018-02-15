//
//  ApiCarsMake.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

struct ApiCarsMake: CarsMakeWithModels, Decodable {
    var makeId: String
    var makeName: String
    var models: [CarsModel]
    
    // MARK: Decode
    
    /*
     {
     "id": "f762a529-6e99-4244-9568-e31b6705edb5",
     "name": "Audi",
     "models": [
         {
         "id": "a243756c-456b-4132-8a6f-c63758551f78",
         "name": "A3",
         },
         {
         "id": "b243756c-456b-4132-8a6f-c63758551f77",
         "name": "A4",
         }
     ]
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        makeId = try keyedContainer.decode(String.self, forKey: .id)
        makeName = try keyedContainer.decode(String.self, forKey: .name)
        models = (try keyedContainer.decode(FailableDecodableArray<ApiCarsModel>.self, forKey: .models)).validElements
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case models
    }
}
