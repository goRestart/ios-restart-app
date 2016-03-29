//
//  UriScheme.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

struct UriScheme {

    var deepLink: DeepLink

    static func buildFromLaunchOptions(launchOptions: [NSObject: AnyObject]) -> UriScheme? {
        guard let url = launchOptions[UIApplicationLaunchOptionsURLKey] as? NSURL else { return nil }
        return UriScheme.buildFromUrl(url)
    }

    static func buildFromUrl(url: NSURL) -> UriScheme? {
        guard let host = url.host, schemeHost = UriSchemeHost(rawValue: host) else { return nil }

        let components = url.components
        let queryParams = url.queryParameters

        return buildFromHost(schemeHost, components: components, params: queryParams)
    }

    static func buildFromHost(host: UriSchemeHost, components: [String], params: [String : String]) -> UriScheme? {
        switch host {
        case .Home:
            return UriScheme(deepLink: .Home)
        case .Sell:
            return UriScheme(deepLink: .Sell)
        case .Product:
            guard let productId = components.first else { return nil }
            return UriScheme(deepLink: .Product(productId: productId))
        case .User:
            guard let userId = components.first else { return nil }
            return UriScheme(deepLink: .User(userId: userId))
        case .Chat:
            if let productId = params["p"], buyerId = params["b"] {
                // letgo://chat/?p=12345&b=abcde where p=product_id, b=buyer_id (user)
                return UriScheme(deepLink: .Conversation(data: .ProductBuyer(productId: productId, buyerId: buyerId)))
            } else if let conversationId = params["c"] {
                // letgo://chat/?c=12345 where c=conversation_id
                return UriScheme(deepLink: .Conversation(data: .Conversation(conversationId: conversationId)))
            } else {
                return nil
            }
        case .Chats:
            return UriScheme(deepLink: .Conversations)
        case .Search:
            guard let query = params["query"] else { return nil }
            return UriScheme(deepLink: .Search(query: query))
        case .ResetPassword:
            guard let token = params["token"] else { return nil }
            return UriScheme(deepLink: .ResetPassword(token: token))
        }
    }
}

enum UriSchemeHost: String {
    case Home = "home"
    case Sell = "sell"
    case Product = "products"
    case User = "users"
    case Chat = "chat"
    case Chats = "chats"
    case Search = "search"
    case ResetPassword = "reset_password"
}
