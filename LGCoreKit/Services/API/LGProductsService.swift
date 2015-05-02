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
//    GET /api/list.{_format}
//    http://devel.api.letgo.com/api/list.json?distance_type=ML&latitude=40.416947&longitude=-3.703528&nr_products=20&offset=0
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
            .validate(statusCode: 200..<300)
            .responseJSON(options: nil, completionHandler: { (request: NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                // Error
                if let actualError = error {
                    if let actualData: AnyObject = data {
                        let json = JSON(actualData)
                        let myError: LGError
                        
                        if let errorResponse = LGSessionErrorResponse(json: json) {
                            myError = LGError(type: .Server(.Session), explanation: errorResponse.error)
                        }
                        else {
                            myError = LGError(type: .Internal(.Parsing), explanation: "Unexpected JSON format")
                        }
                        completion(products: nil, lastPage: nil, error: myError)
                    }
                    else if actualError.domain == NSURLErrorDomain {
                        let myError: LGError = LGError(type: .Network, explanation: actualError.localizedDescription)
                        completion(products: nil, lastPage: nil, error: myError)
                    }
                    else {
                        let myError: LGError = LGError(type: .Internal(LGInternalErrorCode.Unexpected), explanation: actualError.localizedDescription)
                        completion(products: nil, lastPage: nil, error: myError)
                    }
                }
                // Success
                else if let actualData: AnyObject = data {
                    let json = JSON(actualData)
                    if let productsResponse = LGProductsResponse(json: json) {
                        completion(products: productsResponse.products, lastPage: productsResponse.lastPage, error: nil)
                    }
                    else {
                        let myError: LGError = LGError(type: .Internal(.Parsing))
                        completion(products: nil, lastPage: nil, error: myError)
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
                params["query_string"] = queryString
            }
            params["latitude"] = coordinates.latitude
            params["longitude"] = coordinates.longitude
      
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
            
            params["access_token"] = accessToken
            
            return params
        }
    }
}
