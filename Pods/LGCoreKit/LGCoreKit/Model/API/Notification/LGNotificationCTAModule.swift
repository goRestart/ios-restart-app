//
//  LGNotificationCTAModule.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 27/02/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol NotificationCTAModule {
    var title: String { get }
    var deeplink: String { get }
}

public struct LGNotificationCTAModule: NotificationCTAModule, Decodable {
    public let title: String
    public let deeplink: String

    // MARK: Decodable

    /**
     Expects a json in the form:
     {
     "text": "some text",
     "deeplink": "some deeplink that can't be null"
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        title = try keyedContainer.decode(String.self, forKey: .title)
        deeplink = try keyedContainer.decode(String.self, forKey: .deeplink)
    }

    enum CodingKeys: String, CodingKey {
        case title = "text"
        case deeplink = "deeplink"
    }
}

