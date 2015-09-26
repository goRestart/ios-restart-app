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
    
        :param: userId The user id.
        :param: sessionToken The user session token.
        :param: data The data to upload.
        :param: result The closure containing the result.
    */
    func uploadFileWithUserId(userId: String, sessionToken: String, data: NSData, result: FileUploadServiceResult?)
    
    /**
        Upload the data into a file.
    
        :param: userId The user id.
        :param: sessionToken The user session token.
        :param: sourceURL The URL where data is, that should be downloaded and later uploaded to a remote file.
        :param: result The closure containing the result.
    */
    func uploadFileWithUserId(userId: String, sessionToken: String, sourceURL: NSURL, result: FileUploadServiceResult?)
    
    
    /**
        Synchronously, upload the data into a file.
    
        :param: userId The user id.
        :param: sessionToken The user session token.
        :param: data The data to upload.
        :returns: The result.
    */
    func synchUploadFileWithUserId(userId: String, sessionToken: String, data: NSData) -> Result<File, FileUploadServiceError>
}
