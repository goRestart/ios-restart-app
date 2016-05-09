//
//  UniversalLink.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

struct UniversalLink {

    let deepLink: DeepLink

    static func buildFromUserActivity(userActivity: NSUserActivity) -> UniversalLink? {
        guard let url = userActivity.webpageURL else { return nil }
        return UniversalLink.buildFromUrl(url)
    }

    /**
     Initializer using Universal and Handoff links (Links in the web form)

     Valid urls are in the form:
     {whatever}.letgo.com -> Main
     {whatever}.letgo.com/<language_code> -> Main
     {whatever}.letgo.com/<language_code>/u/{userslug}_{user_id} -> User
     {whatever}.letgo.com/<language_code>/i/{productslug}_{product_id} -> Product
     {whatever}.letgo.com/<language_code>/q/<query>?categories=1,2,3... -> Search
     {whatever}.letgo.com/<language_code>/scq/<state>/<city>/<query>?categories=1,2,3... -> Search
     {whatever}.letgo.com/<language_code>/reset-password-renew?token=<token> -> Reset Password
     {whatever}.letgo.com/<language_code>/account-chat-conversation/<conversation_id> -> specific chat
     {whatever}.letgo.com/<language_code>/account-chat-list -> chats tab
     {whatever}.letgo.com/<language_code>/v/<product_id>/<template_id> -> commercializer video link
     {whatever}.letgo.com/<language_code>/vm/<product_id>/<template_id> -> commercializer ready

     Or same as uri schemes but startig with {whatever}.letgo.com, such as:
     {whatever}.letgo.com/products/{product_id} is the same as letgo://products/{product_id}

     - parameter webUrl: Url in the web form: https://es.letgo.com/es/u/... or http:/www.letgo.com/product/....
     */
    private static func buildFromUrl(url: NSURL) -> UniversalLink? {

        guard let host = url.host where host.hasSuffix("letgo.com") else {
            //Any nil object or host different than *letgo.com will be treated as error
            return nil
        }
        let components = url.components
        let queryParams = url.queryParameters

        if components.count > 1 { //the ones with <language_code> part
            switch components[1] {
            case "i":
                guard components.count > 2, let productId = components.last?.decomposeIdSlug() else { return nil }
                return UniversalLink(deepLink: DeepLink.link(.Product(productId: productId)))
            case "u":
                guard components.count > 2, let userId = components.last?.decomposeIdSlug() else { return nil }
                return UniversalLink(deepLink: DeepLink.link(.User(userId: userId)))
            case "q", "scq":
                guard components.count > 2, let query = components.last else { return nil }
                return UniversalLink(deepLink: DeepLink.link(.Search(query: query, categories: queryParams["categories"])))
            case "account-chat-list":
                return UniversalLink(deepLink: DeepLink.link(.Conversations))
            case "account-chat-conversation":
                guard components.count > 2, let conversationId = components.last else { return nil }
                return UniversalLink(deepLink: DeepLink.link(.Conversation(data: .Conversation(conversationId: conversationId))))
            case "reset-password-renew":
                guard let token = queryParams["token"] else { return nil }
                return UniversalLink(deepLink: DeepLink.link(.ResetPassword(token: token)))
            case "v":
                guard components.count > 3 else { return nil }
                let productId = components[2]
                let templateId = components[3]
                return UniversalLink(deepLink: DeepLink.link(.Commercializer(productId: productId, templateId: templateId)))
            case "vm":
                guard components.count > 3 else { return nil }
                let productId = components[2]
                let templateId = components[3]
                return UniversalLink(deepLink: DeepLink.link(.CommercializerReady(productId: productId, templateId: templateId)))
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

        return UniversalLink(deepLink: DeepLink.link(.Home))
    }
}
