//
//  LGNoticationModules.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 27/02/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//


import Argo
import Curry
import Runes

public struct LGNotificationTextModule: NotificationTextModule {
    public let title: String?
    public let body: String
    public let deeplink: String?
}

extension LGNotificationTextModule: Decodable {
    private struct JSONKeys {
        static let title = "title_text"
        static let body = "body_text"
        static let deeplink = "deeplink"
    }
    
    public static func decode(_ j: JSON) -> Decoded<LGNotificationTextModule> {
        /*
         {
         "title_text": "THIS MIGHT BE NULL",
         "body_text": "this can't be null",
         "deeplink": "THIS MIGHT BE NULL"
         }
         */
        return curry(LGNotificationTextModule.init)
            <^> j <|? JSONKeys.title
            <*> j <| JSONKeys.body
            <*> j <|? JSONKeys.deeplink
    }
}


public struct LGNotificationCTAModule: NotificationCTAModule {
    public let title: String
    public let deeplink: String
}

extension LGNotificationCTAModule: Decodable {
    private struct JSONKeys {
        static let text = "text"
        static let deeplink = "deeplink"
    }
    
    public static func decode(_ j: JSON) -> Decoded<LGNotificationCTAModule> {
        /*
         {
         "text": "some text",
         "deeplink": "some deeplink that can't be null"
         }
         */
        return curry(LGNotificationCTAModule.init)
            <^> j <| JSONKeys.text
            <*> j <| JSONKeys.deeplink
    }
}


public struct LGNotificationImageModule: NotificationImageModule {
    public let shape: ImageShape?
    public let imageURL: String
    public let deeplink: String?
}

extension LGNotificationImageModule: Decodable {
    private struct JSONKeys {
        static let shape    = "shape"
        static let imageURL = "image"
        static let deeplink = "deeplink"
    }
    
    init(shape: String?, imageURL: String, deeplink: String?) {
        if let shapeValue = shape {
            self.shape = ImageShape(rawValue: shapeValue) ?? .square
        } else {
            self.shape = nil
        }
        self.imageURL = imageURL
        self.deeplink = deeplink
    }
    
    public static func decode(_ j: JSON) -> Decoded<LGNotificationImageModule> {
        /*
         {
         "shape": "circle" // circle or square, might be nil
         "image": "some url that can't be null",
         "deeplink": "THIS MIGHT BE NULL"         }
         */
        return curry(LGNotificationImageModule.init)
            <^> j <|? JSONKeys.shape
            <*> j <| JSONKeys.imageURL
            <*> j <|? JSONKeys.deeplink
    }
}
