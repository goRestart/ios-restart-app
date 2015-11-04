//
//  LGFileUploadService.swift
//  LGCoreKit
//
//  Created by Dídac on 28/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

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

    public func uploadFileWithUserId(userId: String, sessionToken: String, data: NSData, completion: FileUploadServiceCompletion?) {
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        Alamofire.upload(.POST, url, headers: headers, multipartFormData: {
                multipartFormData in
                multipartFormData.appendBodyPart(data: userId.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "userId")
                multipartFormData.appendBodyPart(data: data, name: "image", fileName: "image.jpg", mimeType: "image/jpg")
            },
            encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _ ):
                    upload.validate(statusCode: 200..<400)
                    .responseObject { (response: Response<LGUploadFileResponse, NSError>) in
                        // Success                        
                        if let uploadFileResponse = response.result.value {
                            var file = LGFile(url: nil)
                            file.objectId = uploadFileResponse.imageId
                            completion?(FileUploadServiceResult(value: file))
                        }
                        // Error
                        else if let error = response.result.error {
                            if error.domain == NSURLErrorDomain {
                                completion?(FileUploadServiceResult(error: .Network))
                            }
                            else if let statusCode = response.response?.statusCode {
                                switch statusCode {
                                case 403:
                                    completion?(FileUploadServiceResult(error: .Forbidden))
                                default:
                                    completion?(FileUploadServiceResult(error: .Internal))
                                }
                            }
                            else {
                                completion?(FileUploadServiceResult(error: .Internal))
                            }
                        }
                    }
                case .Failure(_):
                    completion?(FileUploadServiceResult(error: .Internal))
                }
            })
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
