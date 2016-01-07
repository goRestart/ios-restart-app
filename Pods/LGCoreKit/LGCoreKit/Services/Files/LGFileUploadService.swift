//
//  LGFileUploadService.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 11/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Result

final public class LGFileUploadService: FileUploadService {

    public func uploadFileWithUserId(userId: String, sessionToken: String, data: NSData,
        progress: (Int -> ())? = nil, completion: FileUploadServiceCompletion?) {

            let request = FileRouter.Upload
            ApiClient.upload(request, decoder: LGFileUploadService.decoder, multipart: { multipartFormData in
                if let userIdData = userId.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
                    multipartFormData.appendBodyPart(data: userIdData, name: "userId")
                }
                multipartFormData.appendBodyPart(data: data, name: "image", fileName: "image.jpg", mimeType: "image/jpg")
            }, completion: { result in
                if let value = result.value {
                    let file = LGFile(id: value, url: nil)
                    completion?(FileUploadServiceResult(value: file))
                } else if let error = result.error {
                    completion?(FileUploadServiceResult(error: FileUploadServiceError(apiError: error)))
                } else {
                    completion?(FileUploadServiceResult(error: .Internal))
                }
            }) { (written, totalWritten, totalExpectedToWrite) -> Void in
                let p = totalWritten*100/totalExpectedToWrite
                progress?(Int(p))
            }
    }

    public func uploadFileWithUserId(userId: String, sessionToken: String, sourceURL: NSURL,
        completion: FileUploadServiceCompletion?) {

        let request = NSURLRequest(URL: sourceURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response: NSURLResponse?, data: NSData?, error: NSError?) in

            if let actualData = data {
                self.uploadFileWithUserId(userId, sessionToken: sessionToken, data: actualData, completion: completion)
            } else if let _ = error {
                completion?(FileUploadServiceResult(error: .Network))
            } else {
                completion?(FileUploadServiceResult(error: .Internal))
            }
        }
    }

    static func decoder(object: AnyObject) -> String? {
        let theImage: String? = JSON.parse(object) <| "imageId"
        return theImage
    }
}
