//
//  MediaPermissions.swift
//  LetGo
//
//  Created by Juan Iglesias on 22/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Photos

enum MediaType: String {
    case video
    case audio
    case text
    case closedCaption
    case subtitle
    case timecode
    case metadata
    case muxed
}


protocol MediaPermissions {
    var isCameraAvailable: Bool { get }
    var libraryAuthorizationStatus: PHAuthorizationStatus { get }
    func requestAccess(forMediaType mediaType: MediaType, completionHandler handler: @escaping ((Bool) -> Void))
    func authorizationStatus(forMediaType mediaType: MediaType) -> AVAuthorizationStatus
}


class LGMediaPermissions: MediaPermissions {
    var isCameraAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    var libraryAuthorizationStatus: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    func requestAccess(forMediaType mediaType: MediaType, completionHandler handler: @escaping ((Bool) -> Void)) {
        AVCaptureDevice.requestAccess(forMediaType: getAVMediaType(for: mediaType), completionHandler: handler)
    }
    
    func authorizationStatus(forMediaType mediaType: MediaType) -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(forMediaType: getAVMediaType(for: mediaType))
    }
    
    private func getAVMediaType(for type: MediaType) -> String {
        switch type {
        case .video:
            return AVMediaTypeVideo
        case .audio:
            return AVMediaTypeAudio
        case .text:
            return AVMediaTypeText
        case .closedCaption:
            return AVMediaTypeClosedCaption
        case .subtitle:
            return AVMediaTypeSubtitle
        case .timecode:
            return AVMediaTypeTimecode
        case .metadata:
            return AVMediaTypeMetadata
        case .muxed:
            return AVMediaTypeMuxed
        }
    }
}
