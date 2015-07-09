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
    public static let endpoint = "/api/list.json"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        self.url = baseURL + LGProductsRetrieveService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    public func retrieveProductsWithParams(params: RetrieveProductsParams, result: ProductsRetrieveServiceResult?) {        
        let parameters = params.letgoApiParams
        Alamofire.request(.GET, url, parameters: parameters)
            .validate(statusCode: 200..<400)
            .responseObject { (_, _, productsResponse: LGProductsResponse?, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    let myError: NSError
                    println(">>>> \(actualError.domain)")
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