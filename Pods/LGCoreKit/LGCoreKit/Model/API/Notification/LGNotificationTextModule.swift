//
//  LGNotificationTextModule.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 07/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol NotificationTextModule {
    var title: String? { get }
    var body: String { get }
    var deeplink: String? { get }
}

public struct LGNotificationTextModule: NotificationTextModule, Decodable {
    public let title: String?
    public let body: String
    public let deeplink: String?
    
    // MARK: - Decodable
    
    /*
     {
     "title_text": "THIS MIGHT BE NULL",
     "body_text": "this can't be null",
     "deeplink": "THIS MIGHT BE NULL"
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        title = try keyedContainer.decodeIfPresent(String.self, forKey: .title)
        body = try keyedContainer.decode(String.self, forKey: .body)
        deeplink = try keyedContainer.decodeIfPresent(String.self, forKey: .deeplink)
    }
    
    enum CodingKeys: String, CodingKey {
        case title = "title_text"
        case body = "body_text"
        case deeplink
    }
}
