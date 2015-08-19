//
//  FileUploadService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum FileUploadServiceError {
    case Network
    case Internal
}

public typealias FileUploadServiceResult = (Result<File, FileUploadServiceError>) -> Void
public typealias MultipleFilesUploadServiceResult = (Result<[File], FileUploadServiceError>) -> Void

public protocol FileUploadService {
    
    /**
        Upload the data into a file.
    
        :param: name The filename.
        :param: data The data to upload.
        :param: result The closure containing the result.
    */
    func uploadFile(name: String?, data: NSData, result: FileUploadServiceResult?)
    
    /**
        Upload the data into a file.
    
        :param: name The filename.
        :param: sourceURL The URL where data is, that should be downloaded and later uploaded to a remote file.
        :param: result The closure containing the result.
    */
    func uploadFile(name: String?, sourceURL: NSURL, result: FileUploadServiceResult?)
    
    /**
        Synchronously, upload the data into a file.
    
        :param: name The filename.
        :param: data The data to upload.
        :returns: The result.
    */
    func synchUploadFile(name: String?, data: NSData) -> Result<File, FileUploadServiceError>
}
