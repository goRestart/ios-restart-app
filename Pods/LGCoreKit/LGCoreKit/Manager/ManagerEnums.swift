//
//  ManagerEnums.swift
//  LGCoreKit
//
//  Created by AHL on 17/6/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Result

public enum UserLogInFBError: ErrorType {
    case Cancelled
    case EmailTaken
    case UsernameTaken
    case Forbidden
    case Network
    case Internal
    case InvalidPassword
    case PasswordMismatch
    
    init(_ userLogInFBServiceError: UserLogInFBServiceError) {
        switch(userLogInFBServiceError) {
        case .Cancelled:
            self = .Cancelled
        case .Forbidden:
            self = .Forbidden
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
        case .Forbidden:
            self = .Forbidden
        }
    }
    
    init(_ userSaveServiceError: UserSaveServiceError) {
        switch(userSaveServiceError) {
        case .Network:
            self = .Network
        case .EmailTaken:
            self = .EmailTaken
        case .UsernameTaken:
            self = .Internal      // Should never happen
        case .Internal:
            self = .Internal
        case .InvalidUsername:    // Should never happen
            self = .Internal
        case .InvalidPassword:
            self = .InvalidPassword
        case .PasswordMismatch:
            self = .InvalidPassword
        }
    }
}
public typealias UserLogInFBResult = Result<MyUser, UserLogInFBError>
public typealias UserLogInFBCompletion = UserLogInFBResult -> Void

public enum FileUploadError: ErrorType {
    case Network
    case Internal
    case Forbidden
    
    init(_ fileUploadServiceError: FileUploadServiceError) {
        switch(fileUploadServiceError) {
        case .Network:
            self = .Network
        case .Internal:
            self = .Internal
        case .Forbidden:
            self = .Forbidden
        }
    }
    
    init(_ userSaveServiceError: UserSaveServiceError) {
        switch(userSaveServiceError) {
        case .Network:
            self = .Network
        case .Internal:
            self = .Internal
        case .EmailTaken:   // Should never happen
            self = .Internal
        case .UsernameTaken:   // Should never happen
            self = .Internal
        case .InvalidUsername:   // Should never happen
            self = .Internal
        case .InvalidPassword:   // Should never happen
            self = .Internal
        case .PasswordMismatch:   // Should never happen
            self = .Internal
        }
    }
}

public typealias FileUploadResult = Result<File, FileUploadError>
public typealias FileUploadCompletion = FileUploadResult -> Void

public enum SaveUserCoordinatesError: ErrorType {
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
        case .EmailTaken:   // Should never happen
            self = .Internal
        case .UsernameTaken:   // Should never happen
            self = .Internal
        case .InvalidUsername:   // Should never happen
            self = .Internal
        case .InvalidPassword:   // Should never happen
            self = .Internal
        case .PasswordMismatch:   // Should never happen
            self = .Internal
        }
    }
}

public typealias SaveUserCoordinatesResult = Result<CLLocationCoordinate2D, SaveUserCoordinatesError>
public typealias SaveUserCoordinatesCompletion = SaveUserCoordinatesResult -> Void


