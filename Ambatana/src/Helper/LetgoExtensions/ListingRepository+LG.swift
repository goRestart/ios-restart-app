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
    
    func updateAction(_ shouldUseCarEndpoint: Bool) -> ((ListingEditionParams, ListingCompletion?) -> ()) {
        return shouldUseCarEndpoint ?  updateCar : update
    }
    
    func updateAction(forParams params: ListingEditionParams,
                      shouldUseCarEndpoint: Bool,
                      shouldUseServicesEndpoint: Bool) -> ((ListingEditionParams, ListingCompletion?) -> ()) {
        switch params {
        case .car:
            return updateAction(shouldUseCarEndpoint)
        case .service:
            return shouldUseServicesEndpoint ? updateService : update
        case .product, .realEstate:
            return update
        }
    }
}
