//
//  PAFileUploadService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

final public class PAFileUploadService: FileUploadService {
    
    // MARK: - Lifecycle
    
    public init() {
        
    }
    
    // MARK: - FileUploadService
    
    public func uploadFile(data: NSData, completion: FileUploadCompletion) {
        let file = PFFile(data: data)
        file.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if let actualError = error {
                completion(file: nil, error: actualError)
            }
            else if success {
                completion(file: file, error: nil)
            }
            else {
                completion(file: file, error: NSError(code: LGErrorCode.Internal))
            }
        }
    }
    
    public func uploadFile(sourceURL: NSURL, completion: FileUploadCompletion) {
        let request = NSURLRequest(URL: sourceURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            // Error
            if let actualError = error {
                completion(file: nil, error: actualError)
            }
            // Success
            else if let actualData = data {
                self.uploadFile(actualData, completion: completion)
            }
            // Other error
            else {
                completion(file: nil, error: NSError(code: LGErrorCode.Internal))
            }
        }
    }
}
