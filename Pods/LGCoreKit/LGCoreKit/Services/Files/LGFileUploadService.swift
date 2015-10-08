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

    public func uploadFileWithUserId(userId: String, sessionToken: String, data: NSData, result: FileUploadServiceResult?) {
        
        var params = Dictionary<String, AnyObject>()
        
        let stringSessionToken : String = sessionToken
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: stringSessionToken
        ]
        Alamofire.upload(.POST, URLString: url, headers: headers, multipartFormData: {
                multipartFormData in
                multipartFormData.appendBodyPart(data: userId.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: userId)
                multipartFormData.appendBodyPart(data: data, name: "image", fileName: "image.jpg", mimeType: "image/jpg")
            },
            encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _ ):
                    upload.validate(statusCode: 200..<400)
                    .responseObject { (_, response, uploadFileResponse: LGUploadFileResponse?, error: NSError?) -> Void in
                        // Error
                        if let actualError = error {
                            if actualError.domain == NSURLErrorDomain {
                                result?(Result<File, FileUploadServiceError>.failure(.Network))
                            } else if let statusCode = response?.statusCode {
                                switch statusCode {
                                case 403:
                                    result?(Result<File, FileUploadServiceError>.failure(.Forbidden))
                                default:
                                    result?(Result<File, FileUploadServiceError>.failure(.Internal))
                                }
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
    
    public func uploadFileWithUserId(userId: String, sessionToken: String, sourceURL: NSURL, result: FileUploadServiceResult?) {
        let request = NSURLRequest(URL: sourceURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            // Success
            if let actualData = data {
                self.uploadFileWithUserId(userId, sessionToken: sessionToken, data: actualData, result: result)
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
    
    public func synchUploadFileWithUserId(userId: String, sessionToken: String, data: NSData) -> Result<File, FileUploadServiceError> {
        
        var result = Result<File, FileUploadServiceError>.failure(.Internal)
        
        let formData = LGMultipartFormData()
        formData.appendBodyPart(data: userId.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, name: "userId")
        formData.appendBodyPart(data: data, name: "image", fileName: "image.jpg", mimeType: "image/jpg")
        let httpHeaders = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken,
            "Accept": "*/*"
        ]
        
        // Build the request
        if let url = NSURL(string: url), request = NSMutableURLRequest.synchFileUpload(data, formData: formData, url: url, httpHeaders: httpHeaders) {
            
            // Run the connection
            var error: NSError?
            var response: NSURLResponse?
            if let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error) {
                
                // Success
                if let httpResponse = response as? NSHTTPURLResponse {
                    let statusCode = httpResponse.statusCode
                    
                    // Validate status code (200..<400)
                    if statusCode >= 200 && statusCode < 400 {

                        // Build the response & the file
                        if  let json: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: nil),
                            let fileUploadResponse = LGUploadFileResponse(response: httpResponse, representation: json) {
                            var file = LGFile(url: nil)
                            file.token = fileUploadResponse.imageId
                            result = Result<File, FileUploadServiceError>.success(file)
                        }
                    } else if statusCode == 403 {
                        result = Result<File, FileUploadServiceError>.failure(.Forbidden)
                    }
                    // Otherwise, gives an error internal
                }
                // Error (network)
                else {
                    result = Result<File, FileUploadServiceError>.failure(.Network)
                }
            }
        }
        
        return result
    }
}
