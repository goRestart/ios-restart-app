//
//  LGProductsFavouriteRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 02/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result
import Argo

final public class LGProductsFavouriteRetrieveService: ProductsFavouriteRetrieveService {

    public init() {}

    public func retrieveFavouriteProducts(user: User, completion: ProductsFavouriteRetrieveServiceCompletion?) {

        guard let userId = user.objectId else {
            completion?(ProductsFavouriteRetrieveServiceResult(error: .Internal))
            return
        }

        struct CustomProductsFavoriteResponse: ProductsFavouriteResponse {
            var products: [Product]
        }

        let request = ProductRouter.IndexFavorites(userId: userId)
        ApiClient.request(request, decoder: LGProductsFavouriteRetrieveService.decoder) {
            (result: Result<[Product], ApiError>) -> () in

            if let value = result.value {
                completion?(ProductsFavouriteRetrieveServiceResult(value: CustomProductsFavoriteResponse(products: value)))
            } else if let error = result.error {
                completion?(ProductsFavouriteRetrieveServiceResult(error: ProductsFavouriteRetrieveServiceError(apiError: error)))
            }
        }
    }

    static func decoder(object: AnyObject) -> [Product]? {
        guard let theLGProducts : [LGProduct] = decode(object) else {
            return nil
        }
        return theLGProducts.map({$0})
    }
}
