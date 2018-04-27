//
//  ListingRepository+LG.swift
//  LetGo
//
//  Created by Tomas Cobo on 25/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

extension ListingRepository {
    func createAction(_ shouldUseCarEndpoint: Bool) -> ((ListingCreationParams, ListingCompletion?) -> ()) {
        return shouldUseCarEndpoint ?  createCar : create 
    }
}
