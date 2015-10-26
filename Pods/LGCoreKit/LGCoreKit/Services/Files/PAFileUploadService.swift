//
//  PAFileUploadService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAFileUploadService: FileUploadService {
    
    // MARK: - Lifecycle
    
    public init() {
        
    }
    
    // MARK: - FileUploadService
    
    public func uploadFileWithUserId(userId: String, sessionToken: String, data: NSData, completion: FileUploadServiceCompletion?) {
        
        guard let file = PFFile(name: "image.jpg", data: data) else {
            completion?(FileUploadServiceResult(error: .Internal))
            return
        }
        
        file.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            // Success
            if success {
                completion?(FileUploadServiceResult(value: file))
            }
            // Error
            else if let actualError = error {
                switch(actualError.code) {
                case PFErrorCode.ErrorConnectionFailed.rawValue:
                    completion?(FileUploadServiceResult(error: .Network))
                default:
                    completion?(FileUploadServiceResult(error: .Internal))
                }
            }
            else {
                completion?(FileUploadServiceResult(error: .Internal))
            }
        }
    }
    
    public func uploadFileWithUserId(userId: String, sessionToken: String, sourceURL: NSURL, completion: FileUploadServiceCompletion?) {
        let request = NSURLRequest(URL: sourceURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            // Success
            if let actualData = data {
                self.uploadFileWithUserId(userId, sessionToken: sessionToken, data: actualData, completion: completion)
            }
            // Error
            else if let _ = error {
                completion?(FileUploadServiceResult(error: .Network))
            }
            else {
                completion?(FileUploadServiceResult(error: .Internal))
            }
        }
    }
}
