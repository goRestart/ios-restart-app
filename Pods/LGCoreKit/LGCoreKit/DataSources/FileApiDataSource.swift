//
//  FileApiDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 12/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result
import Argo


final class FileApiDataSource: FileDataSource {
 
    static let sharedInstance = FileApiDataSource()
    
    func uploadFile(userId: String, data: NSData, imageName: String, progress: (Float -> ())? = nil, completion: FileDataSourceCompletion?) {
        let request = FileRouter.Upload
        
        ApiClient.upload(request, decoder: FileApiDataSource.decoder, multipart: { multipart in
            if let userIdData = userId.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
                multipart.appendBodyPart(data: userIdData, name: "userId")
            }
            multipart.appendBodyPart(data: data, name: imageName, fileName: imageName+".jpg", mimeType: "image/jpg")
            }, completion: completion) { (written, totalWritten, totalExpectedToWrite) in
                let p = Float(totalWritten)/Float(totalExpectedToWrite)
                progress?(p)
        }
    }
    
    
    // MARK: - Decoders
    
    static func decoder(object: AnyObject) -> String? {
        let theImage: String? = JSON.parse(object) <| "imageId"
        return theImage
    }
}
