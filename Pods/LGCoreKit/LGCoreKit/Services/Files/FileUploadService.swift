//
//  FileUploadService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum FileUploadServiceError: ErrorType {
    case Network
    case Internal
    case Forbidden


    init(apiError: ApiError) {
        switch apiError {
        case .Unauthorized:
            self = .Forbidden
        case .Network:
            self = .Network
        case .Internal, .NotFound, .Scammer, .AlreadyExists, .InternalServerError:
            self = .Internal
        }
    }
}

public typealias FileUploadServiceResult = Result<File, FileUploadServiceError>
public typealias FileUploadServiceCompletion = FileUploadServiceResult -> Void

public typealias MultipleFilesUploadServiceResult = Result<[File], FileUploadServiceError>
public typealias MultipleFilesUploadServiceCompletion = MultipleFilesUploadServiceResult -> Void

public protocol FileUploadService {

    /**
        Upload the data into a file.

        - parameter userId: The user id.
        - parameter sessionToken: The user session token.
        - parameter data: The data to upload.
        - parameter completion: The completion closure.
    */
    func uploadFileWithUserId(userId: String, sessionToken: String, data: NSData, progress: (Int -> ())?, completion: FileUploadServiceCompletion?)

    /**
        Upload the data into a file.

        - parameter userId: The user id.
        - parameter sessionToken: The user session token.
        - parameter sourceURL: The URL where data is, that should be downloaded and later uploaded to a remote file.
        - parameter completion: The completion closure.
    */
    func uploadFileWithUserId(userId: String, sessionToken: String, sourceURL: NSURL, completion: FileUploadServiceCompletion?)
}
