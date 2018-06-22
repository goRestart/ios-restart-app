//
//  ListingRepository+LG.swift
//  LetGo
//
//  Created by Tomas Cobo on 25/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

extension ListingRepository {

    func updateAction(forParams params: ListingEditionParams,
                      shouldUseServicesEndpoint: Bool) -> ((ListingEditionParams, ListingCompletion?) -> ()) {
        switch params {
        case .service:
            // TODO: Once the A/B Test is finished, remove this check and move logic to corekit
            return shouldUseServicesEndpoint ? updateService : update
        case .product, .realEstate, .car:
            return update
        }
    }
}
