//
//  LGUserProductsRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 09/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result
import Argo

final public class LGUserProductsRetrieveService: UserProductsRetrieveService {

    public init() {}

    public func retrieveUserProductsWithParams(params: RetrieveProductsParams, completion: ProductsRetrieveServiceCompletion?) {

        guard let userId = params.userObjectId  else {
            completion?(ProductsRetrieveServiceResult(error: .Internal))
            return
        }

        struct CustomProductsResponse: ProductsResponse {
            var products: [Product]
        }

        let request = ProductRouter.IndexForUser(userId: userId, params: params.userProductApiParams)
        ApiClient.request(request, decoder: LGUserProductsRetrieveService.decoder) {
            (result : Result<[Product], ApiError>) -> () in

            if let value = result.value {
                completion?(ProductsRetrieveServiceResult(value: CustomProductsResponse(products: value)))
            } else if let error = result.error {
                completion?(ProductsRetrieveServiceResult(error: ProductsRetrieveServiceError(apiError: error)))
            }
        }
    }

    static func decoder(object: AnyObject) -> [Product]? {
        guard let theProduct : [LGProduct] = decode(object) else {
            return nil
        }
        
        return theProduct.map{$0}
    }
}

extension RetrieveProductsParams {
    var userProductApiParams: Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>()
        
        params["num_results"] = numProducts
        params["offset"] = offset
        
        // TODO: Think twice about this :-P
        if self.statuses == [.Sold, .SoldOld] {
            params["status"] = UserProductStatus.Sold.rawValue
        } else {
            params["status"] = UserProductStatus.Selling.rawValue
        }
        
        return params
    }
}
