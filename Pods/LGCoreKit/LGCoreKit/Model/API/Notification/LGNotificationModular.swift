//
//  LGNotificationModular.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 27/02/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol NotificationModular {
    var text: NotificationTextModule { get }
    var callToActions: [NotificationCTAModule] { get }
    var basicImage: NotificationImageModule? { get }
    var iconImage: NotificationImageModule? { get }
    var heroImage: NotificationImageModule? { get }
    var thumbnails: [NotificationImageModule]? { get }
}

public struct LGNotificationModular: NotificationModular, Decodable {
    public let text: NotificationTextModule
    public let callToActions: [NotificationCTAModule]
    public let basicImage: NotificationImageModule?
    public let iconImage: NotificationImageModule?
    public let heroImage: NotificationImageModule?
    public let thumbnails: [NotificationImageModule]?
    
    // MARK: - Decodable

    /*
     {
        "text": {
            "title_text": "THIS MIGHT BE NULL",
            "body_text": "this can't be null",
            "deeplink": "THIS MIGHT BE NULL"
        },
        "cta": [{
        "text": "some text",
        "deeplink": "some deeplink that can't be null"
        }, {
        "text": "some text",
        "deeplink": "some deeplink that can't be null"
        }, {
        "text": "some text",
        "deeplink": "some deeplink that can't be null"
        }],
        "basic_image": {
            "shape": "circle",
            "image": "some url that can't be null",
            "deeplink": "THIS MIGHT BE NULL"
        },
        "icon_image": {
            "image": "some url that can't be null"
        },
        "hero_image": {
            "image": "some url that can't be null",
            "deeplink": "THIS MIGHT BE NULL"
        },
        "thumbnails": [{
        "shape": "circle",
        "image": "some url that can't be null",
        "deeplink": "some deeplink that can't be null"
        }, {
        "shape": "square",
        "image": "some url that can't be null",
        "deeplink": "some deeplink that can't be null"
        }, {
        "shape": "circle",
        "image": "some url that can't be null",
        "deeplink": "some deeplink that can't be null"
        }, {
        "shape": "square",
        "image": "some url that can't be null",
        "deeplink": "some deeplink that can't be null"
        }]
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        text = try keyedContainer.decode(LGNotificationTextModule.self, forKey: .text)
        callToActions = try keyedContainer.decode([LGNotificationCTAModule].self, forKey: .callToActions)
        basicImage = try keyedContainer.decodeIfPresent(LGNotificationImageModule.self, forKey: .basicImage)
        iconImage = try keyedContainer.decodeIfPresent(LGNotificationImageModule.self, forKey: .iconImage)
        heroImage = try keyedContainer.decodeIfPresent(LGNotificationImageModule.self, forKey: .heroImage)
        thumbnails = try keyedContainer.decodeIfPresent([LGNotificationImageModule].self, forKey: .thumbnails)
    }
    
    enum CodingKeys: String, CodingKey {
        case text
        case callToActions = "cta"
        case basicImage = "basic_image"
        case iconImage = "icon_image"
        case heroImage = "hero_image"
        case thumbnails = "thumbnails"
    }
}

