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
    func requestLibraryAuthorization(completionHandler handler: @escaping (PHAuthorizationStatus) -> Void)
   
}


class LGMediaPermissions: MediaPermissions {
    var isCameraAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    var videoAuthorizationStatus: AuthorizationStatus {
        return getCameraAuthStatus(from: AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo))
    }
    
    var libraryAuthorizationStatus: AuthorizationStatus {
        return getLibraryAuthStatus(from: PHPhotoLibrary.authorizationStatus())
    }
    
    func requestVideoAccess(completionHandler handler: @escaping ((Bool) -> Void)) {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: handler)
    }
    
    func requestLibraryAuthorization(completionHandler handler: @escaping (PHAuthorizationStatus) -> Void) {
        
    }
    
    
    fileprivate func getCameraAuthStatus(from avAuthorizationStatus: AVAuthorizationStatus) -> AuthorizationStatus {
        switch avAuthorizationStatus {
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
    
    fileprivate func getLibraryAuthStatus(from phAuthorizationStatus: PHAuthorizationStatus) -> AuthorizationStatus {
        switch phAuthorizationStatus {
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
