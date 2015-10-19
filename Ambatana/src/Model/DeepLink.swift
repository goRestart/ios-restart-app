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
    case Home = "home", Sell = "sell", Product = "products", User = "users"
}

/**
    Deep link.
*/
public struct DeepLink: CustomStringConvertible {
    private var url: NSURL
    var type: DeepLinkType
    var components: [String]
    var query: [String: String]
    
    var isValid: Bool {
        switch type {
        case .Home, .Sell:
            return true
        case .Product, .User:
            return components.count > 0
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
        {country}.letgo.com/{language} -> main screen
        {country}.letgo.com/{language}/u/{userslug}_{user_id} -> user profile
        {country}.letgo.com/{language}/i/{productslug}_{product_id} -> product
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
        
        if urlComponents.count == 1 { // just the language -> main screen
            self.type = DeepLinkType.Home
        }
        else if urlComponents.count == 3 { //Product or user
            //Decomposing slug
            let slugComponents = urlComponents[2].componentsSeparatedByString("_")
            if slugComponents.count > 1 {
                let slugId = slugComponents[slugComponents.count - 1]
                self.components.append(slugId)
            }
            
            switch urlComponents[1]{
                case "u":
                    self.type = DeepLinkType.User
                case "i":
                    self.type = DeepLinkType.Product
                default:
                    return nil
            }
        }
        else {
            return nil
        }

        parseQuery(url.query)
    }
    
    private mutating func parseQuery(queryString: String?){
        if let q = queryString {
            let mergedKeyValues = q.componentsSeparatedByString("&")
            for mergedKeyValue in mergedKeyValues {
                let keyValue = mergedKeyValue.componentsSeparatedByString("=")
                if keyValue.count == 2 {
                    //if let key = keyValue[0].stringByRemovingPercentEncoding(NSUTF8StringEncoding), let value = keyValue[1].stringByRemovingPercentEncoding(NSUTF8StringEncoding) {
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
        
        // If last character is "/" then remove it; Swift 2.0: String(output.characters.dropLast())
        let idx = output.endIndex.advancedBy(-1)
        let lastChar = output.substringFromIndex(idx)
        if lastChar == "/" {
            let idx = output.characters.count - 1
            output = output.substringToIndex(output.startIndex.advancedBy(idx))
        }
        return output
    }
}
