//
//  Alamofire.Request+LG.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire

extension Alamofire.Request {
    public func responseObject<T: ResponseObjectSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) -> Self {
        let serializer: Serializer = { (request, response, data) in
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            
            if let response = response, JSON: AnyObject = JSON {
                return (T(response: response, representation: JSON), nil)
            } else {
                return (nil, serializationError)
            }
        }
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            completionHandler(request, response, object as? T, error)
        })
    }
}