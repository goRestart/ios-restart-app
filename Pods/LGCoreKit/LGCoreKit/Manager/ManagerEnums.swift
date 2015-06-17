//
//  ManagerEnums.swift
//  LGCoreKit
//
//  Created by AHL on 17/6/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Result

public enum UserLogInFBError {
    case Cancelled
    case Network
    case Internal
    
    init(_ userLogInFBServiceError: UserLogInFBServiceError) {
        switch(userLogInFBServiceError) {
        case .Cancelled:
            self = .Cancelled
        case .Internal:
            self = .Internal
        }
    }
    
    init(_ fbUserInfoRetrieveServiceError: FBUserInfoRetrieveServiceError) {
        switch(fbUserInfoRetrieveServiceError) {
        case .General:
            self = .Network
        case .Internal:
            self = .Internal
        }
    }
    
    init(_ fileUploadServiceError: FileUploadServiceError) {
        switch(fileUploadServiceError) {
        case .Network:
            self = .Network
        case .Internal:
            self = .Internal
        }
    }
    
    init(_ userSaveServiceError: UserSaveServiceError) {
        switch(userSaveServiceError) {
        case .Network:
            self = .Network
        case .Internal:
            self = .Internal
        }
    }
}
public typealias UserLogInFBResult = (Result<User, UserLogInFBError>) -> Void

public enum FileUploadError {
    case Network
    case Internal
    
    init(_ fileUploadServiceError: FileUploadServiceError) {
        switch(fileUploadServiceError) {
        case .Network:
            self = .Network
        case .Internal:
            self = .Internal
        }
    }
    
    init(_ userSaveServiceError: UserSaveServiceError) {
        switch(userSaveServiceError) {
        case .Network:
            self = .Network
        case .Internal:
            self = .Internal
        }
    }
}
public typealias FileUploadResult = (Result<File, FileUploadError>) -> Void

public enum SaveUserCoordinatesError {
    case Network
    case Internal
    
    init(_ postalAddressRetrievalServiceError: PostalAddressRetrievalServiceError) {
        switch(postalAddressRetrievalServiceError) {
        case .Network:
            self = .Network
        case .Internal:
            self = .Internal
        }
    }
    
    init(_ userSaveServiceError: UserSaveServiceError) {
        switch(userSaveServiceError) {
        case .Network:
            self = .Network
        case .Internal:
            self = .Internal
        }
    }
}
public typealias SaveUserCoordinatesResult = (Result<CLLocationCoordinate2D, SaveUserCoordinatesError>) -> Void
