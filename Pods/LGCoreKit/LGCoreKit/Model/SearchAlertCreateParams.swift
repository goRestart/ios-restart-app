//
//  SearchAlertCreateParams.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 12/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

struct SearchAlertCreateParams {
    
    private struct Keys {
        static let objectId = "user_search_alert_id"
        static let query = "query"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let createdAt = "created_at"
    }
    
    let objectId: String
    let query: String
    let latitude: Double
    let longitude: Double
    let createdAt: TimeInterval
    
    var apiParams: [String : Any] {
        return [Keys.objectId : objectId,
                Keys.query : query,
                Keys.latitude : latitude,
                Keys.longitude : longitude,
                Keys.createdAt : createdAt]
    }
    
    public init(objectId: String, query: String, latitude: Double, longitude: Double, createdAt: TimeInterval) {
        self.objectId = objectId
        self.query = query
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
    }
}

