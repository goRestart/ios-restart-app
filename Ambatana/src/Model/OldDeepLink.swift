//
//  DeepLink.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//


/**
    Deep link types, describes host.
*/
public enum DeepLinkType: String {
    case Home = "home"
    case Sell = "sell"
    case Product = "products"
    case ProductSlug = "product_slug"
    case User = "users"
    case Chat = "chat"
    case Chats = "chats"
    case Search = "search"
    case ResetPassword = "reset_password"

    //INIT FOR UNIVERSAL LINKS
    init?(webUrl: NSURL) {
        
        guard var urlComponents = webUrl.pathComponents else { return nil }
        // Take the components and remove the first item that is always just a "/"
        if !urlComponents.isEmpty {
            urlComponents.removeAtIndex(0)
        }
        
        if urlComponents.count == 3 {
            if urlComponents[1] == "i" {
                self = .ProductSlug
            } else if urlComponents[1] == "u" {
                self = .User
            } else if urlComponents[1] == "q" {
                self = .Search
            } else if urlComponents[1] == "account-chat-conversation" {
                self = .Chat
            } else {
                return nil
            }
        } else if urlComponents.count == 5 && urlComponents[1] == "scq" {
            self = .Search
        } else if urlComponents.count == 2 && urlComponents[0] == "product" {
            self = .Product
        } else if urlComponents.count == 2 && urlComponents[1] == "reset-password-renew" {
            self = .ResetPassword
        } else if urlComponents.isEmpty {
            self = .Home
        } else if urlComponents.count == 1 {
            guard let fromRaw = DeepLinkType(rawValue: urlComponents[0]) else { return nil }
            self = fromRaw
        }
        else {
            return nil
        }
    }
}

/**
    Deep link.
*/
public struct OldDeepLink: CustomStringConvertible {
    private var url: NSURL
    var type: DeepLinkType
    var components: [String]
    var query: [String: String]
    
    var isValid: Bool {
        switch type {
        case .Home, .Sell, .Chats:
            return true
        case .Product, .User, .ProductSlug:
            return components.count > 0
        case .Chat:
            // letgo://chat/?p=12345&b=abcde where p=product_id, b=buyer_id (user)
            // or letgo://chat/?c=12345 where c=conversation_id
            if let _ = query["p"], let _ = query["b"] {
                return true
            } else if let _ = query["c"] {
                return true
            }
            return false
        case .Search:
            return query["query"] != nil
        case .ResetPassword:
            return query["token"] != nil
        }
    }
    
    // MARK: - Lifecycle
    
    /**
        Initializer using Url scheme links
    */
    public init?(url: NSURL) {
        self.url = url
        if let host = url.host, type = DeepLinkType(rawValue: host) {
            self.type = type
        }
        else {
            return nil
        }

        self.components = []
        if let pathComponents = url.pathComponents {
            // Take the components and remove the first item that is always just a "/"
            self.components = pathComponents
            if !self.components.isEmpty {
                self.components.removeAtIndex(0)
            }
        }
        
        self.query = [:]
        parseQuery(url.query)
    }
 
    /**
    Initializer using Universal and Handoff links (Links in the web form)
    
        Valid urls are in the form:
        {whatever}.letgo.com -> main screen
        {country}.letgo.com/{language} -> main screen
        {country}.letgo.com/{language}/u/{userslug}_{user_id} -> user profile
        {country}.letgo.com/{language}/i/{productslug}_{product_id} -> product
        {whatever}.letgo.com/products/{product_id} -> product
        {country}.letgo.com/<language_code>/q/<query> -> Search
        {country}.letgo.com/<language_code>/scq/<state>/<city>/<query> -> Search
        {whatever}.letgo.com/<language_code>/reset-password-renew?token=<token> -> Reset Password
        {whatever}.letgo.com/<language_code>/account-chat-conversation/<conversation_id> -> specific chat
    
    - parameter webUrl: Url in the web form: https://es.letgo.com/es/u/... or http:/www.letgo.com/product/....
    */
    public init?(webUrl: NSURL) {
        self.url = webUrl
        self.components = []
        self.query = [:]
        self.type = DeepLinkType.Home
        
        guard let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true), let host = components.host, let pathComponents = url.pathComponents where host.hasSuffix("letgo.com") else {
            //Any nil object or host different than *letgo.com will be treated as error
            return nil
        }
        
        // Take the components and remove the first item that is always just a "/"
        var urlComponents = pathComponents
        if !urlComponents.isEmpty {
            urlComponents.removeAtIndex(0)
        }
        
        guard let linkType = DeepLinkType(webUrl: url) else { return nil }
        type = linkType
        parseQuery(url.query)

        switch type {
        case .Home, .Sell, .Chats, .ResetPassword:
            break
        case .ProductSlug:
            if let productId = decomposeIdSlug(urlComponents[2]) {
                self.components.append(productId)
            }
        case .Product:
            if !urlComponents[1].characters.isEmpty { // Only if productId is not empty
                self.components.append(urlComponents[1])
            }
        case .User:
            if let userId = decomposeIdSlug(urlComponents[2]) {
                self.components.append(userId)
            }
        case .Search:
            query["query"] = urlComponents.last
        case .Chat:
            query["c"] = urlComponents.last
        }
    }
    
    public init?(action: Action, url: NSURL) {
        
        switch action {
        case let .Message( _ , messageProduct, messageBuyer):
            self.url = url
            self.query = ["p" : messageProduct, "b" : messageBuyer]
            self.components = []
            self.type = .Chat
        case let .Conversation(_, conversationId):
            self.url = url
            self.query = ["c" : conversationId]
            self.components = []
            self.type = .Chat
        case .URL(let actionDeepLink):
            self = actionDeepLink
        }
    }
    
//    public mutating func buildWithAction(action: Action) {
//        
//        switch action {
//        case let .Message( _ , messageProduct, messageBuyer):
//            query = ["p" : messageProduct, "b" : messageBuyer]
//        case let .Conversation(_,  conversationId):
//            query = ["c" : conversationId]
//        case let .URL(actionDeepLink):
//            self = actionDeepLink
//        }
//    }

    private func decomposeIdSlug(sluggedId: String) -> String? {
        let slugComponents = sluggedId.componentsSeparatedByString("_")
        if slugComponents.count > 1 {
            let slugId = slugComponents[slugComponents.count - 1]
            return slugId
        }
        return nil
    }
    
    private mutating func parseQuery(queryString: String?){
        if let q = queryString {
            let mergedKeyValues = q.componentsSeparatedByString("&")
            for mergedKeyValue in mergedKeyValues {
                let keyValue = mergedKeyValue.componentsSeparatedByString("=")
                if keyValue.count == 2 {
                    if let key = keyValue[0].stringByRemovingPercentEncoding, let value = keyValue[1].stringByRemovingPercentEncoding {
                        query[key] = value
                    }
                }
            }
        }
    }
    
    // MARK: - Printable
    
    public var description: String {
        var output = "letgo://\(type.rawValue)/"
        
        if components.count > 0 {
            let path = components.joinWithSeparator("/")
            output += "\(path)"
        }
        if !query.isEmpty {
            output += "?"
            for (key, value) in query {
                output += "\(key)=\(value)"
                output += "&"
            }
            
            // Remove last "&"
            let idx = output.characters.count - 1
            output = output.substringToIndex(output.startIndex.advancedBy(idx))
        }
        
        // If last character is "/" then remove it
        let idx = output.endIndex.advancedBy(-1)
        let lastChar = output.substringFromIndex(idx)
        if lastChar == "/" {
            let idx = output.characters.count - 1
            output = output.substringToIndex(output.startIndex.advancedBy(idx))
        }
        return output
    }
}
