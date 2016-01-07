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

extension RetrieveProductsParams {
    
    var mustShuffle: Bool {
        //If there is a sort criteria different than distance -> no shuffling
        if self.sortCriteria != nil && self.sortCriteria! != .Distance {
            return false
        }
        
        return self.coordinates != nil
    }
    
    var letgoApiParams: Dictionary<String, AnyObject> {
        get {
            var params = Dictionary<String, AnyObject>()

            if let queryString = self.queryString {
                params["search_term"] = queryString
            }
            
            if let coordinates = self.coordinates {
                params["quadkey"] = coordinates.coordsToQuadKey(LGCoreKitConstants.defaultQuadKeyPrecision)
            }
            
            if let countryCode = self.countryCode {
                params["country_code"] = countryCode
            }
            
            if let categoryIds = self.categoryIds {
                if !categoryIds.isEmpty {
                    let categoryIdsString = categoryIds.map { String($0) }
                    params["categories"] = categoryIdsString.joinWithSeparator(",")
                }
            }
            
            if let maxPrice = self.maxPrice {
                params["max_price"] = maxPrice
            }
            
            if let minPrice = self.minPrice {
                params["min_price"] = minPrice
            }
            
            if let distanceRadius = self.distanceRadius {
                params["distance_radius"] = distanceRadius
            }
            
            if let distanceType = self.distanceType {
                params["distance_type"] = distanceType.string
            }
            
            if let numProducts = self.numProducts {
                params["num_results"] = numProducts
            }
            
            if let offset = self.offset {
                params["offset"] = offset
            }
            
            if let sortCriteria = self.sortCriteria, let sortCriteriaValue = sortCriteria.string {
                params["sort"] = sortCriteriaValue
            }
            
            if let timeCriteria = self.timeCriteria, let timeCriteriaValue = timeCriteria.string {
                params["since"] = timeCriteriaValue
            }
            
            return params

        }
    }
}