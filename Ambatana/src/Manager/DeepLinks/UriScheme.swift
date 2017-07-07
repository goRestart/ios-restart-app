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
    static let cardActionKey = "card-action"

    var deepLink: DeepLink

    static func buildFromLaunchOptions(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]) -> UriScheme? {
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
        let cardActionParameter = params[UriScheme.cardActionKey]

        switch host {
        case .home:
            return UriScheme(deepLink: DeepLink.link(.home, campaign: campaign, medium: medium,
                                                     source: source, cardActionParameter: cardActionParameter))
        case .sell:
            return UriScheme(deepLink: DeepLink.link(.sell, campaign: campaign, medium: medium,
                                                     source: source, cardActionParameter: cardActionParameter))
        case .product, .products:
            guard let productId = components.first else { return nil }
            return UriScheme(deepLink: DeepLink.link(.product(productId: productId), campaign: campaign, medium: medium,
                source: source, cardActionParameter: cardActionParameter))
        case .user:
            guard let userId = components.first else { return nil }
            return UriScheme(deepLink: DeepLink.link(.user(userId: userId), campaign: campaign, medium: medium,
                source: source, cardActionParameter: cardActionParameter))
        case .chat:
            if let conversationId = params["c"] {
                // letgo://chat/?c=12345 where c=conversation_id
                return UriScheme(deepLink: DeepLink.link(.conversation(data: .conversation(conversationId: conversationId)),
                    campaign: campaign, medium: medium, source: source, cardActionParameter: cardActionParameter))
            } else if let productId = params["p"], let buyerId = params["b"] {
                // letgo://chat/?p=12345&b=abcde where p=product_id, b=buyer_id (user)
                return UriScheme(deepLink: DeepLink.link(.conversation(data: .productBuyer(productId: productId,
                    buyerId: buyerId)), campaign: campaign, medium: medium, source: source, cardActionParameter: cardActionParameter))
            } else {
                return nil
            }
        case .chats:
            return UriScheme(deepLink: DeepLink.link(.conversations, campaign: campaign, medium: medium,
                                                     source: source, cardActionParameter: cardActionParameter))
        case .search:
            guard let query = params["query"] else { return nil }
            return UriScheme(deepLink: DeepLink.link(.search(query: query, categories: params["categories"]),
                campaign: campaign, medium: medium, source: source, cardActionParameter: cardActionParameter))
        case .resetPassword:
            guard let token = params["token"] else { return nil }
            return UriScheme(deepLink: DeepLink.link(.resetPassword(token: token), campaign: campaign, medium: medium,
                source: source, cardActionParameter: cardActionParameter))
        case .userRatings:
            return UriScheme(deepLink: DeepLink.link(.userRatings, campaign: campaign, medium: medium,
                                                     source: source, cardActionParameter: cardActionParameter))
        case .userRating:
            guard let ratingId = components.first else { return nil }
            return UriScheme(deepLink: DeepLink.link(.userRating(ratingId: ratingId), campaign: campaign, medium: medium,
                source: source, cardActionParameter: cardActionParameter))
        case .passiveBuyers:
            guard let productId = components.first else { return nil }
            return UriScheme(deepLink: DeepLink.link(.passiveBuyers(productId: productId), campaign: campaign, medium: medium,
                source: source, cardActionParameter: cardActionParameter))
        case .appStore:
            return UriScheme(deepLink: DeepLink.link(.appStore, campaign: campaign, medium: medium,
                                                     source: source, cardActionParameter: cardActionParameter))
        }
    }
}

enum UriSchemeHost: String {
    case home = "home"
    case sell = "sell"
    case product = "product"
    case products = "products"
    case user = "users"
    case chat = "chat"
    case chats = "chats"
    case search = "search"
    case resetPassword = "reset_password"
    case userRatings = "userreviews"
    case userRating = "userreview"
    case passiveBuyers = "passive_buyers"
    case appStore = "update_app"
}
