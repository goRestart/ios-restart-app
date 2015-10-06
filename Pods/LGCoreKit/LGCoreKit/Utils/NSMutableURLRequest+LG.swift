//
//  SynchFileUpload.swift
//  LGCoreKit
//
//  Created by AHL on 26/9/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire

extension NSMutableURLRequest {
    public static func synchFileUpload(data: NSData, formData: LGMultipartFormData, url: NSURL, httpHeaders: [String: String]) -> NSMutableURLRequest? {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
                
        // Add headers
        for (httpHeaderKey, httpHeaderValue) in httpHeaders {
            request.setValue(httpHeaderValue, forHTTPHeaderField: httpHeaderKey)
        }

        // Encode the body
        // > In memory if possible
        if formData.contentLength < Manager.MultipartFormDataEncodingMemoryThreshold {
            let encodingResult = formData.encode()
            switch encodingResult {
            case .Success(let data):
                request.HTTPMethod = "POST"
                request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
                request.setValue(String(formData.contentLength), forHTTPHeaderField: "Content-Length")
                request.HTTPBody = data
                break
            case .Failure(let encodingError):
                return nil
            }
        }
        // Otherwise, in disk
        else {
            let fileManager = NSFileManager.defaultManager()
            let tempDirectoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory())!
            let directoryURL = tempDirectoryURL.URLByAppendingPathComponent("com.letgo.ios/multipart.form.data")
            let fileName = NSUUID().UUIDString
            let fileURL = directoryURL.URLByAppendingPathComponent(fileName)
            
            var error: NSError?
            if fileManager.createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil, error: &error) {
                if let error = formData.writeEncodedDataToDisk(fileURL) {
                    return nil
                }
            }
            else {
                return nil
            }
        }
        return request
    }
    
}
