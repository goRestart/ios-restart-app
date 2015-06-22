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
    
    public func uploadFile(data: NSData, result: FileUploadServiceResult?) {
        let file = PFFile(data: data)
        file.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            // Success
            if success {
                result?(Result<File, FileUploadServiceError>.success(file))
            }
            // Error
            else if let actualError = error {
                switch(actualError.code) {
                case PFErrorCode.ErrorConnectionFailed.rawValue:
                    result?(Result<File, FileUploadServiceError>.failure(.Network))
                default:
                    result?(Result<File, FileUploadServiceError>.failure(.Internal))
                }
            }
            else {
                result?(Result<File, FileUploadServiceError>.failure(.Internal))
            }
        }
    }
    
    public func uploadFile(sourceURL: NSURL, result: FileUploadServiceResult?) {
        let request = NSURLRequest(URL: sourceURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            // Success
            if let actualData = data {
                self.uploadFile(actualData, result: result)
            }
            // Error
            else if let actualError = error {
                result?(Result<File, FileUploadServiceError>.failure(.Network))
            }
            else {
                result?(Result<File, FileUploadServiceError>.failure(.Internal))
            }
        }
    }
}
