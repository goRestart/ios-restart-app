//
//  MockMediaPermissions.swift
//  LetGo
//
//  Created by Juan Iglesias on 22/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


@testable import LetGoGodMode
import Foundation
import Photos

class MockMediaPermissions: MediaPermissions {
    
    var isCameraAvailable: Bool = false
    var libraryAuthorizationStatus: PHAuthorizationStatus = .authorized
    
    func requestAccess(forMediaType mediaType: MediaType, completionHandler handler: @escaping ((Bool) -> Void)) { }
    
    func authorizationStatus(forMediaType mediaType: MediaType) -> AVAuthorizationStatus {
        return .authorized
    }
}
