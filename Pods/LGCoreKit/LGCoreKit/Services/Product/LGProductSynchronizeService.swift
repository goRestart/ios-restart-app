//
//  LGProductSynchronizeService.swift
//  LGCoreKit
//
//  Created by AHL on 29/7/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

final public class LGProductSynchronizeService: ProductSynchronizeService {
    
    // Constants
    public static let endpoint = "/api/sincronizedb.json"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        self.url = baseURL + LGProductsRetrieveService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - ProductSynchronizeService
    
    public func synchronizeProductWithId(productId: String, result: ProductSynchronizeServiceResult?) {
        var parameters = Dictionary<String, AnyObject>()
        parameters["product_id"] = productId
        Alamofire.request(.GET, url, parameters: parameters)
            .validate(statusCode: 200..<400)
            .response { (_, _, _, _) -> Void in
                result?()
        }
    }
    
    public func synchSynchronizeProductWithId(productId: String, result: ProductSynchronizeServiceResult?) {
        if let actualURL = NSURL(string: "\(url)?product_id=\(productId)") {
            var request = NSURLRequest(URL: actualURL)
            var response: NSURLResponse?
            var error: NSErrorPointer = nil
            NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: error)
            result?()
        }
    }
}
