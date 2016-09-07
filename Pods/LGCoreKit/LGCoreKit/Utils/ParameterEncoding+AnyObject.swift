//
//  ParameterEncoding+AnyObject.swift
//  LGCoreKit
//
//  Created by Dídac on 19/02/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Alamofire

extension ParameterEncoding {

    /**
     Creates a URL request by encoding parameters and applying them onto an existing request.
     
     - parameter URLRequest: The request to have parameters applied
     - parameter parameters: The parameters to apply
     
     - returns: A tuple containing the constructed request and the error that occurred during parameter encoding,
     if any.
     */
    public func anyObjectEncode( URLRequest: URLRequestConvertible, parameters: AnyObject?)
        -> (NSMutableURLRequest, NSError?) {
            
            let mutableURLRequest = URLRequest.URLRequest
            guard let parameters = parameters else { return (mutableURLRequest, nil) }
            var encodingError: NSError? = nil
            
            switch self {
            case .JSON:
                do {
                    let options = NSJSONWritingOptions()
                    let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: options)
                    
                    mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    mutableURLRequest.HTTPBody = data
                } catch {
                    encodingError = error as NSError
                }
            case .URL, .URLEncodedInURL, .PropertyList, .Custom:
                encodingError = NSError(domain: "com.letgo.ios.LGCoreKit", code: 0,
                    userInfo: ["message": "use 'anyObjectEncode' for JSON encoding only."])
            }
            return (mutableURLRequest, encodingError)
    }
}
