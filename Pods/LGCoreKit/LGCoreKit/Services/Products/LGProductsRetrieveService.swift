//
//  LGProductsRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result
import Argo

final public class LGProductsRetrieveService: ProductsRetrieveService {

    public init() {}

    public func retrieveProductsWithParams(params: RetrieveProductsParams, completion: ProductsRetrieveServiceCompletion?) {

        let request = ProductRouter.Index(params: params.letgoApiParams)

        struct CustomProductsResponse: ProductsResponse {
            var products: [Product]
        }

        ApiClient.request(request, decoder: LGProductsRetrieveService.decoder) {
            (result: Result<[Product], ApiError>) -> () in

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