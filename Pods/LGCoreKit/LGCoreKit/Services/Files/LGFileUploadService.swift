//
//  LGFileUploadService.swift
//  LGCoreKit
//
//  Created by Dídac on 28/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result
import SwiftyJSON

final public class LGFileUploadService: FileUploadService {
    
    // Constants
    public static let endpoint = "/api/products/image"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        self.url = baseURL + LGFileUploadService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - FileUploadService
    
    public func uploadFile(name: String?, data: NSData, result: FileUploadServiceResult?) {
        
        var params = Dictionary<String, AnyObject>()
        
        let stringSessionToken : String = MyUserManager.sharedInstance.myUser()?.sessionToken ?? ""
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: stringSessionToken
        ]
        Alamofire.upload(.POST, URLString: url, headers: headers, multipartFormData: {
                multipartFormData in
                if let userId = MyUserManager.sharedInstance.myUser()?.objectId {
                    multipartFormData.appendBodyPart(data: userId.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "userId")
                }
                multipartFormData.appendBodyPart(data: data, name: "image", fileName: "image.jpg", mimeType: "image/jpg")
            },
            encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _ ):
                    upload.validate(statusCode: 200..<400)
                    .responseObject { (_, _, uploadFileResponse: LGUploadFileResponse?, error: NSError?) -> Void in
                        // Error
                        if let actualError = error {
                            println(actualError)
                            if actualError.domain == NSURLErrorDomain {
                                result?(Result<File, FileUploadServiceError>.failure(.Network))
                            }
                            else {
                                result?(Result<File, FileUploadServiceError>.failure(.Internal))
                            }
                        }
                            // Success
                        else {
                            if let response = uploadFileResponse {
                                var file = LGFile(url: nil)
                                file.token = response.imageId
                                result?(Result<File, FileUploadServiceError>.success(file))
                            }
                        }
                    }
                case .Failure(let encodingError):
                    result?(Result<File, FileUploadServiceError>.failure(.Internal))
                }
            })
    }
    
    public func uploadFile(name: String?, sourceURL: NSURL, result: FileUploadServiceResult?) {
        //        let request = NSURLRequest(URL: sourceURL)
        //        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
        //            // Success
        //            if let actualData = data {
        //                self.uploadFile(name, data: actualData, result: result)
        //            }
        //                // Error
        //            else if let actualError = error {
        //                result?(Result<File, FileUploadServiceError>.failure(.Network))
        //            }
        //            else {
        //                result?(Result<File, FileUploadServiceError>.failure(.Internal))
        //            }
        //        }
    }
}
