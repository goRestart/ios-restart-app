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
    
    public func retrieveProductsWithParams(params: RetrieveProductsParams, result: ProductsRetrieveServiceResult?) {        
        let parameters = params.letgoApiParams
        
        let sessionToken : String = MyUserManager.sharedInstance.myUser()?.sessionToken ?? ""
                
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        
        Alamofire.request(.GET, url, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject { (req, resp, productsResponse: LGProductsResponse?, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    let myError: NSError
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<ProductsResponse, ProductsRetrieveServiceError>.failure(.Network))
                    }
                    else {
                        result?(Result<ProductsResponse, ProductsRetrieveServiceError>.failure(.Internal))
                    }
                }
                // Success
                else if let actualProductsResponse = productsResponse {
                    result?(Result<ProductsResponse, ProductsRetrieveServiceError>.success(actualProductsResponse))
                }
        }
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
                    params["categories"] = ",".join(categoryIdsString)
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