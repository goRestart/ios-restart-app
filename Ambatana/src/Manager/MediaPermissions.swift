//
//  MediaPermissions.swift
//  LetGo
//
//  Created by Juan Iglesias on 22/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Photos

enum AuthorizationStatus {
    case notDetermined
    case restricted
    case denied
    case authorized
}


protocol MediaPermissions {
    var isCameraAvailable: Bool { get }
    var videoAuthorizationStatus: AuthorizationStatus { get }
    var libraryAuthorizationStatus: AuthorizationStatus { get }
    func requestVideoAccess(completionHandler handler: @escaping ((Bool) -> Void))
    func requestLibraryAuthorization(completionHandler handler: @escaping (AuthorizationStatus) -> Void)
   
}


class LGMediaPermissions: MediaPermissions {
    var isCameraAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    var videoAuthorizationStatus: AuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo).authorizationStatus
    }
    
    var libraryAuthorizationStatus: AuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus().authorizationStatus
    }
    
    func requestVideoAccess(completionHandler handler: @escaping ((Bool) -> Void)) {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: handler)
    }
    
    func requestLibraryAuthorization(completionHandler handler: @escaping (AuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) in
            handler(status.authorizationStatus)
        }
    }
}

extension AVAuthorizationStatus {
    var authorizationStatus: AuthorizationStatus {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        }
    }
}

extension PHAuthorizationStatus {
    var authorizationStatus: AuthorizationStatus {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        }
    }
}
