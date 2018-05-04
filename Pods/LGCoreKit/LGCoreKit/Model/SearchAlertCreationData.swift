//
//  SearchAlertCreationData.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 25/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public struct SearchAlertCreationData {
    public let objectId: String?
    public let query: String
    public var isCreated: Bool
    public var isEnabled: Bool

    public init(objectId: String?, query: String, isCreated: Bool, isEnabled: Bool) {
        self.objectId = objectId
        self.query = query
        self.isCreated = isCreated
        self.isEnabled = isEnabled
    }
}
