//
//  UniversalLink.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

struct UniversalLink {

    static let utmMediumKey = "utm_medium"
    static let utmSourceKey = "utm_source"
    static let utmCampaignKey = "utm_campaign"
    static let cardAction = "cardAction"

    let deepLink: DeepLink

    static func buildFromUserActivity(_ userActivity: NSUserActivity) -> UniversalLink? {
        // we don't need to handle Branch links as we will get the branch object in the callback
        guard !isBranchDeepLink(userActivity) else { return nil }

        guard let url = userActivity.webpageURL else { return nil }
        return UniversalLink.buildFromUrl(url)
    }

    /**
     Initializer using Universal and Handoff links (Links in the web form)

     Valid urls are in the form:
     {country}.letgo.com -> Main
     {country}.letgo.com/<language_code> -> Main
     {country}.letgo.com/<language_code>/u/{userslug}_{user_id} -> User
     {country}.letgo.com/<language_code>/i/{productslug}_{product_id} -> Product
     {country}.letgo.com/<language_code>/q/<query>?categories=1,2,3... -> Search
     {country}.letgo.com/<language_code>/scq/<state>/<city>/<query>?categories=1,2,3... -> Search
     {country}.letgo.com/<language_code>/reset-password-renew?token=<token> -> Reset Password
     {country}.letgo.com/<language_code>/account-chat-conversation/<conversation_id> -> specific chat
     {country}.letgo.com/<language_code>/account-chat-list -> chats tab

     Or same as uri schemes but startig with {whatever}.letgo.com, such as:
     {country}.letgo.com/products/{product_id} is the same as letgo://products/{product_id}

     - parameter webUrl: Url in the web form: https://es.letgo.com/es/u/... or http:/www.letgo.com/product/....
     */
    private static func buildFromUrl(_ url: URL) -> UniversalLink? {
        guard let host = url.host, host.hasSuffix("letgo.com") else {
            //Any nil object or host different than *letgo.com will be treated as error
            return nil
        }
        let components = url.components
        let queryParams = url.queryParameters

        let campaign = queryParams[UniversalLink.utmCampaignKey]
        let medium = queryParams[UniversalLink.utmMediumKey]
        let source = DeepLinkSource(string: queryParams[UniversalLink.utmSourceKey])
        let cardAction = queryParams[UniversalLink.cardAction]

        if components.count > 1 { //the ones with <language_code> part
            switch components[1] {
            case "i":
                guard components.count > 2, let productId = components.last?.decomposeIdSlug() else { return nil }
                return UniversalLink(deepLink: DeepLink.link(.product(productId: productId), campaign: campaign, medium: medium, source: source, cardActionParameter: cardAction))
            case "u":
                guard components.count > 2, let userId = components.last?.decomposeIdSlug() else { return nil }
                return UniversalLink(deepLink: DeepLink.link(.user(userId: userId), campaign: campaign, medium: medium, source: source, cardActionParameter: cardAction))
            case "q", "scq":
                guard components.count > 2, let query = components.last else { return nil }
                return UniversalLink(deepLink: DeepLink.link(.search(query: query, categories: queryParams["categories"]), campaign: campaign, medium: medium, source: source, cardActionParameter: cardAction))
            case "account-chat-list":
                return UniversalLink(deepLink: DeepLink.link(.conversations, campaign: campaign, medium: medium, source: source, cardActionParameter: cardAction))
            case "account-chat-conversation":
                guard components.count > 2, let conversationId = components.last else { return nil }
                return UniversalLink(deepLink: DeepLink.link(.conversation(data: .conversation(conversationId: conversationId)), campaign: campaign, medium: medium, source: source, cardActionParameter: cardAction))
            case "reset-password-renew":
                guard let token = queryParams["token"] else { return nil }
                return UniversalLink(deepLink: DeepLink.link(.resetPassword(token: token), campaign: campaign, medium: medium, source: source, cardActionParameter: cardAction))
            default: break
            }
        }
        if let schemeHost = components.first, let uriSchemeHost = UriSchemeHost(rawValue: schemeHost) {
            // the ones same as uri scheme but with {whatever}.letgo.com/ instead of letgo://
            var schemeComponents = components
            schemeComponents.removeFirst() // First component is the host on uriSchemes
            if let uriScheme = UriScheme.buildFromHost(uriSchemeHost, components: schemeComponents, params: queryParams){
                return UniversalLink(deepLink: uriScheme.deepLink)
            }
        }

        return UniversalLink(deepLink: DeepLink.link(.home, campaign: campaign, medium: medium, source: source, cardActionParameter: cardAction))
    }

    static func isBranchDeepLink(_ userActivity: NSUserActivity) -> Bool {
        guard let url = userActivity.webpageURL else { return false }
        return UniversalLink.isBranchDeepLink(url)
    }

    private static func isBranchDeepLink(_ url: URL) -> Bool {
        guard let host = url.host  else { return false }
        return host == Constants.branchLinksHost
    }
}
