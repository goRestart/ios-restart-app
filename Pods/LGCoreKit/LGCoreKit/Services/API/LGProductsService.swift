//
//  LGProductsService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import SwiftyJSON

final public class LGProductsService: ProductsService {

    // Constants
    public static let endpoint = "/api/list.json"

    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        self.url = baseURL + LGProductsService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    public func retrieveProductsWithParams(params: RetrieveProductsParams, completion: RetrieveProductsCompletion) {
        
        let parameters = params.letgoApiParams
        Alamofire.request(.GET, url, parameters: parameters)
            .validate(statusCode: 200..<400)
            .responseJSON(options: nil, completionHandler: { (request: NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                // Error
                if let actualError = error {
                    let myError: NSError
                    if let actualData: AnyObject = data {
                        let json = JSON(actualData)
                        
                        myError = NSError(code: LGErrorCode.Parsing)
                        completion(products: nil, lastPage: nil, error: myError)
                    }
                    else if actualError.domain == NSURLErrorDomain {
                        myError = NSError(code: LGErrorCode.Network)
                        completion(products: nil, lastPage: nil, error: myError)
                    }
                    else {
                        myError = NSError(code: LGErrorCode.Internal)
                        completion(products: nil, lastPage: nil, error: myError)
                    }
                }
                // Success
                else if let actualData: AnyObject = data {
                    // TODO: Refactor this bg parsing with custom response handle in Alamofire
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                        
                        let json = JSON(actualData)
                        if let productsResponse = LGProductsResponseParser.responseWithJSON(json) {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                completion(products: productsResponse.products, lastPage: productsResponse.lastPage, error: nil)
                            })
                            
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                let myError = NSError(code: LGErrorCode.Parsing)
                                completion(products: nil, lastPage: nil, error: myError)
                            })
                        }
                    })
                }
            })
    }
}

extension RetrieveProductsParams {
    var letgoApiParams: Dictionary<String, AnyObject> {
        get {
            var params = Dictionary<String, AnyObject>()
            if let queryString = self.queryString {
                params["query_string"] = queryString
            }
            
            if let coordinates = self.coordinates {
                params["latitude"] = coordinates.latitude
                params["longitude"] = coordinates.longitude
            }
      
            if let categoryIds = self.categoryIds {
                if !categoryIds.isEmpty {
                    let categoryIdsString = categoryIds.map { String($0) }
                    params["category_id"] = ",".join(categoryIdsString)
                }
            }
            
            if let sortCriteria = self.sortCriteria, let sortCriteriaValue = sortCriteria.string {
                params["sort_by"] = sortCriteriaValue
            }
            
            if let distanceType = self.distanceType {
                params["distance_type"] = distanceType.string
            }
            
            if let offset = self.offset {
                params["offset"] = offset
            }
            
            if let numProducts = self.numProducts {
                params["nr_products"] = numProducts
            }
            
            if let statuses = self.statuses {
                if !statuses.isEmpty {
                    let statusesString = statuses.map { String($0.rawValue) }
                    params["status"] = ",".join(statusesString)
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
            
            if let userObjectId = self.userObjectId {
                params["user_object_id"] = userObjectId
            }
            
            return params
        }
    }
}
