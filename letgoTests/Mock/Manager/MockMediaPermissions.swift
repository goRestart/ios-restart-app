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
    var videoAuthorizationStatus: AuthorizationStatus = .authorized
    var libraryAuthorizationStatus: AuthorizationStatus = .authorized
    
    func requestVideoAccess(completionHandler handler: @escaping ((Bool) -> Void)) { }
    func requestLibraryAuthorization(completionHandler handler: @escaping (PHAuthorizationStatus) -> Void) { }
}
