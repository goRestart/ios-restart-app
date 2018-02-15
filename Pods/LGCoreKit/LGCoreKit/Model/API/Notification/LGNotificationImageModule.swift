//
//  LGNotificationImageModule.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 07/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol NotificationImageModule {
    var shape: NotificationImageShape? { get }
    var imageURL: String { get }
    var deeplink: String? { get }
}

public struct LGNotificationImageModule: NotificationImageModule, Decodable {
    public let shape: NotificationImageShape?
    public let imageURL: String
    public let deeplink: String?
    
    // MARK: - Decodable
    
    /*
     {
     "shape": "circle" // circle or square, might be nil
     "image": "some url that can't be null",
     "deeplink": "THIS MIGHT BE NULL"
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        shape = try keyedContainer.decodeIfPresent(NotificationImageShape.self, forKey: .shape)
        imageURL = try keyedContainer.decode(String.self, forKey: .imageURL)
        deeplink = try keyedContainer.decodeIfPresent(String.self, forKey: .deeplink)
    }
    
    enum CodingKeys: String, CodingKey {
        case shape
        case imageURL = "image"
        case deeplink
    }
}
