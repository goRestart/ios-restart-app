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
    let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    
    // MARK: - FileDataSource
    
    func uploadFile(userId: String, data: NSData, imageName: String, progress: (Float -> ())? = nil, completion: FileDataSourceCompletion?) {
        let request = FileRouter.Upload
        
        apiClient.upload(request, decoder: FileApiDataSource.decoder, multipart: { multipart in
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
        let imageId: Decoded<String> = JSON(object) <| "imageId"
        return imageId.value
    }
}
