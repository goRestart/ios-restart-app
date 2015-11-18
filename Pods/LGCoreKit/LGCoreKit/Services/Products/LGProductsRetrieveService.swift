//
//  LGProductsRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

final public class LGProductsRetrieveService: ProductsRetrieveService {
    
    // Constants
    public static let endpoint = "/api/products"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        self.url = baseURL + LGProductsRetrieveService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - ProductsRetrieveService
    
    public func retrieveProductsWithParams(params: RetrieveProductsParams, completion: ProductsRetrieveServiceCompletion?) {
        let parameters = params.letgoApiParams
        
        let sessionToken : String = MyUserManager.sharedInstance.myUser()?.sessionToken ?? ""
                
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        
        Alamofire.request(.GET, url, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject({ (productsResponse: Response<LGProductsResponse, NSError>) -> Void in
                // Error
                if let actualError = productsResponse.result.error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(ProductsRetrieveServiceResult(error: .Network))
                    }
                    else {
                        completion?(ProductsRetrieveServiceResult(error: .Internal))
                    }
                }
                // Success
                else if let actualProductsResponse = productsResponse.result.value {
                    
                    //Shuffling only when there isn't sort criteria and there are coordinates
                    if params.mustShuffle {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                            // Background thread -> shuffle products
                            let shuffledProducts = actualProductsResponse.shuffledProducts(params.coordinates!)
                            dispatch_async(dispatch_get_main_queue()) {
                                // Main thread
                                completion?(ProductsRetrieveServiceResult(value: LGProductsResponse(products: shuffledProducts)))
                            }
                        }
                    }
                    else{
                        //Without coordinates we just return the results
                        completion?(ProductsRetrieveServiceResult(value: actualProductsResponse))
                    }
                }
            })
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
            
            return params

        }
    }
}