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
                    print(actualError)
                    print(productsResponse.response)
                    if actualError.domain == NSURLErrorDomain {
                        completion?(ProductsRetrieveServiceResult(error: .Network))
                    }
                    else {
                        completion?(ProductsRetrieveServiceResult(error: .Internal))
                    }
                }
                // Success
                else if let actualProductsResponse = productsResponse.result.value {
                    
                    if let coordinates = params.coordinates {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                            // Background thread -> shuffle products
                            actualProductsResponse.products = actualProductsResponse.shuffledProducts(coordinates)
                            dispatch_async(dispatch_get_main_queue()) {
                                // Main thread
                                completion?(ProductsRetrieveServiceResult(value: actualProductsResponse))
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