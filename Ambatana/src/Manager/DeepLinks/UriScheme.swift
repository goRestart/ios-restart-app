//
//  UriScheme.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

struct UriScheme {

    static let utmMediumKey = "utm_medium"
    static let utmSourceKey = "utm_source"
    static let utmCampaignKey = "utm_campaign"

    var deepLink: DeepLink

    static func buildFromLaunchOptions(_ launchOptions: [AnyHashable: Any]) -> UriScheme? {
        guard let url = launchOptions[UIApplicationLaunchOptionsKey.url] as? URL else { return nil }
        return UriScheme.buildFromUrl(url)
    }

    static func buildFromUrl(_ url: URL) -> UriScheme? {
        guard let host = url.host, let schemeHost = UriSchemeHost(rawValue: host) else { return nil }

        let components = url.components
        let queryParams = url.queryParameters

        return buildFromHost(schemeHost, components: components, params: queryParams)
    }

    static func buildFromHost(_ host: UriSchemeHost, components: [String], params: [String : String]) -> UriScheme? {

        let campaign = params[UriScheme.utmCampaignKey]
        let medium = params[UriScheme.utmMediumKey]
        let source = DeepLinkSource(string: params[UriScheme.utmSourceKey])

        switch host {
        case .Home:
            return UriScheme(deepLink: DeepLink.link(.home, campaign: campaign, medium: medium, source: source))
        case .sell:
            return UriScheme(deepLink: DeepLink.link(.sell, campaign: campaign, medium: medium, source: source))
        case .Product, .Products:
            guard let productId = components.first else { return nil }
            return UriScheme(deepLink: DeepLink.link(.product(productId: productId), campaign: campaign, medium: medium,
                source: source))
        case .User:
            guard let userId = components.first else { return nil }
            return UriScheme(deepLink: DeepLink.link(.user(userId: userId), campaign: campaign, medium: medium,
                source: source))
        case .Chat:
            if let conversationId = params["c"] {
                // letgo://chat/?c=12345 where c=conversation_id
                return UriScheme(deepLink: DeepLink.link(.conversation(data: .conversation(conversationId: conversationId)),
                    campaign: campaign, medium: medium, source: source))
            } else if let productId = params["p"], let buyerId = params["b"] {
                // letgo://chat/?p=12345&b=abcde where p=product_id, b=buyer_id (user)
                return UriScheme(deepLink: DeepLink.link(.conversation(data: .productBuyer(productId: productId,
                    buyerId: buyerId)), campaign: campaign, medium: medium, source: source))
            } else {
                return nil
            }
        case .Chats:
            return UriScheme(deepLink: DeepLink.link(.conversations, campaign: campaign, medium: medium, source: source))
        case .Search:
            guard let query = params["query"] else { return nil }
            return UriScheme(deepLink: DeepLink.link(.search(query: query, categories: params["categories"]),
                campaign: campaign, medium: medium, source: source))
        case .ResetPassword:
            guard let token = params["token"] else { return nil }
            return UriScheme(deepLink: DeepLink.link(.resetPassword(token: token), campaign: campaign, medium: medium,
                source: source))
        case .Commercializer:
            guard let productId = params["p"], let templateId = params["t"] else { return nil }
            return UriScheme(deepLink: DeepLink.link(.commercializerReady(productId: productId, templateId: templateId),
                campaign: campaign, medium: medium, source: source))
        case .UserRatings:
            return UriScheme(deepLink: DeepLink.link(.userRatings, campaign: campaign, medium: medium, source: source))
        case .UserRating:
            guard let ratingId = components.first else { return nil }
            return UriScheme(deepLink: DeepLink.link(.userRating(ratingId: ratingId), campaign: campaign, medium: medium,
                source: source))
        case .PassiveBuyers:
            guard let productId = components.first else { return nil }
            return UriScheme(deepLink: DeepLink.link(.passiveBuyers(productId: productId), campaign: campaign, medium: medium,
                source: source))
        }
    }
}

enum UriSchemeHost: String {
    case Home = "home"
    case Sell = "sell"
    case Product = "product"
    case Products = "products"
    case User = "users"
    case Chat = "chat"
    case Chats = "chats"
    case Search = "search"
    case ResetPassword = "reset_password"
    case Commercializer = "commercializer"
    case UserRatings = "userreviews"
    case UserRating = "userreview"
    case PassiveBuyers = "passive_buyers"
}
