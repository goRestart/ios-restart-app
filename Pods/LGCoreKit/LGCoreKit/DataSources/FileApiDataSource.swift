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
    
    func uploadFile(_ userId: String, data: Data, imageName: String, progress: ((Float) -> ())? = nil, completion: FileDataSourceCompletion?) {
        let request = FileRouter.upload

        apiClient.upload(request, decoder: FileApiDataSource.decoder, multipart: { multipart in
            if let userIdData = userId.data(using: .utf8, allowLossyConversion: true) {
                multipart.append(userIdData, withName: "userId")
            }
            multipart.append(data, withName: imageName, fileName: imageName+".jpg", mimeType: "image/jpg")
        }, completion: completion) { progressData in
            let p: Float
            if progressData.totalUnitCount > 0 {
                p = Float(progressData.completedUnitCount)/Float(progressData.totalUnitCount)
            } else {
                p = 0
            }
            progress?(p)
        }
    }
    
    
    // MARK: - Decoders
    
    static func decoder(_ object: Any) -> String? {
        let imageId: Decoded<String> = JSON(object) <| "imageId"
        return imageId.value
    }
}
