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
public struct DeepLink: Printable {
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
    
    public init?(url: NSURL) {
        if let host = url.host, type = DeepLinkType(rawValue: host) {
            self.type = type
        }
        else {
            return nil
        }

        self.components = []
        if let path = url.path {
            // Take the components and remove the first item that is always just a "/"
            self.components = path.pathComponents
            if !self.components.isEmpty {
                self.components.removeAtIndex(0)
            }
        }
        
        self.query = [:]
        if let q = url.query {
            let mergedKeyValues = q.componentsSeparatedByString("&")
            for mergedKeyValue in mergedKeyValues {
                let keyValue = mergedKeyValue.componentsSeparatedByString("=")
                if keyValue.count == 2 {
                    if let key = keyValue[0].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding), let value = keyValue[1].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
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
            let path = "/".join(components)    // Swift 2.0: components.joinWithSeparator("/")
            output += "\(path)"
        }
        if !query.isEmpty {
            output += "?"
            for (key, value) in query {
                output += "\(key)=\(value)"
                output += "&"
            }
            
            // Remove last "&"
            let idx = count(output) - 1
            output = output.substringToIndex(advance(output.startIndex, idx))
        }
        
        // If last character is "/" then remove it; Swift 2.0: String(output.characters.dropLast())
        let idx = advance(output.endIndex, -1)
        let lastChar = output.substringFromIndex(idx)
        if lastChar == "/" {
            let idx = count(output) - 1
            output = output.substringToIndex(advance(output.startIndex, idx))
        }
        return output
    }
}
