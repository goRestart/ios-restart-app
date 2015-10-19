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
    var url: NSURL
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
        if let q = url.query {
            let mergedKeyValues = q.componentsSeparatedByString("&")
            for mergedKeyValue in mergedKeyValues {
                let keyValue = mergedKeyValue.componentsSeparatedByString("=")
                if keyValue.count == 2 {
//                    if let key = keyValue[0].stringByRemovingPercentEncoding(NSUTF8StringEncoding), let value = keyValue[1].stringByRemovingPercentEncoding(NSUTF8StringEncoding) {
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
