//
//  SearchAlert.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 09/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol SearchAlert: BaseModel {
    var query: String { get }
    var enabled: Bool { get }
    var createdAt: TimeInterval { get }
    
    init(objectId: String?, query: String, enabled: Bool, createdAt: TimeInterval)
}
