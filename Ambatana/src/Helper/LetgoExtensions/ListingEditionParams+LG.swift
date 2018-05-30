//
//  ListingEditionParams+LG.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 07/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

extension ListingEditionParams {
    func updating(price: ListingPrice) -> ListingEditionParams {
        switch self {
        case .product(let productParams):
            let newParams = productParams
            newParams.price = price
            return ListingEditionParams.product(newParams)
        case .car(let carParams):
            let newParams = carParams
            newParams.price = price
            return ListingEditionParams.car(newParams)
        case .realEstate(let realEstateParams):
            let newParams = realEstateParams
            newParams.price = price
            return ListingEditionParams.realEstate(newParams)
        case .service(let serviceParams):
            let newParams = serviceParams
            newParams.price = price
            return ListingEditionParams.service(newParams)
        }
    }
}
