//
//  FileUploadService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol FileUploadService {
    
    /**
        Upload the data into a file.
    
        :param: data The data to upload.
        :param: completion The completion closure.
    */
    func uploadFile(data: NSData, completion: FileUploadCompletion)
    
    /**
        Upload the data into a file.
    
        :param: sourceURL The URL where data is, that should be downloaded and later uploaded to a file.
        :param: completion The completion closure.
    */
    func uploadFile(sourceURL: NSURL, completion: FileUploadCompletion)
}
